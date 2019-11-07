# frozen_string_literal: true

module GraphqlRelationHelper
  def has_many(relation)
    model = relation.to_s.camelcase.singularize
    field relation, ["Types::#{model}Type".constantize], null: false do
      argument :query, "Types::#{model}QueryType".constantize, required: false
    end

    define_method relation do |req = nil|
      if req
        query = req[:query].to_h
        query[:id] = query.delete(:ids) if query.key?(:ids)
      end

      if object
        object.send(relation).where(query)
      else
        model.constantize.where(query)
      end
    end
  end

  def belongs_to(name)
    field name, "Types::#{name.to_s.capitalize}Type".constantize, null: false

    define_method name do |query: nil|
      object.send(name)
    end
  end
end
