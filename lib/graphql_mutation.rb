# frozen_string_literal: true

require 'active_support/concern'

# Usage:
#   class UserOps < GraphQL::Schema::Object
#     include GraphqlMutation
#     is_mutation_of User
#
#     ...any overwrites here
#   end
#
#   or inline
#
#   UserOps = GraphqlMutation.create_ops_for User
module GraphqlMutation
  extend ActiveSupport::Concern
  def self.create_ops_for(model)
    Class.new(GraphQL::Schema::Object) do
      include GraphqlMutation
      is_mutation_of model
    end
  end

  included do
    def self.is_mutation_of(model)
      create = proc do |_, args, _ctx|
        model.create! args.input.to_h
      end

      update = proc do |instance, args, _ctx|
        instance.update! args.input.to_h
        instance.reload
      end

      destroy = proc do |instance|
        instance.destroy!
        instance.id
      rescue Exception => e
        nil
      end

      class_eval do
        @model = model

        field :create, "Types::#{model.name}Type", null: false,
                                                   resolve: create do
          argument :input, "Types::#{model.name}InputType", required: true
        end

        field :update, "Types::#{model.name}Type", null: false,
                                                   resolve: update do
          argument :input, "Types::#{model.name}InputType", required: true
        end

        field :destroy, GraphQL::Types::ID, null: true, resolve: destroy
      end
    end

    # def self.for(belongs_to, as:)
    #   relation = as
    #   model = @model
    #   klass = Class.new(self) do
    #     create = proc do |_, args, _ctx|
    #       debugger
    #       belongs_to.send(relation).create(args.to_h)
    #     end
    #
    #     field :create, "Types::#{model.name}Type", null: false, resolve: create do
    #       argument :input, "Types::#{model.name}InputType", required: false
    #     end
    #   end
    #
    #   return klass
    # end
    #
    # def self.has_many(relation)
    #   # NOTE: relation can't be inlined, it needs to be saved in a file
    #   self.class_eval do
    #     model = relation.to_s.camelcase.singularize
    #     relationOps = "Mutations::#{model}Ops".constantize
    #
    #     resolver = proc do |object, args, ctx|
    #       if(args["id"])
    #         object.send(relation).find_by(args.to_h)
    #       else
    #         relationOps.for(object, as: relation)
    #       end
    #     end
    #
    #     field relation, "Mutations::#{model}Ops", null: false,
    #         resolve: resolver do
    #       argument :id, GraphQL::Types::ID, required: false
    #     end
    #   end
    # end
  end
end
