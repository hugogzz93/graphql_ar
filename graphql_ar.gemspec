Gem::Specification.new do |s|
  s.name = 'graphql_ar'
  s.version = '0.0.0'
  s.date = '2019-11-07'
  s.summary = 'Helps integrate graphql with active record'
  s.authors = 'Hugo González'
  s.email = 'pinelo93@gmail.com'
  s.files = ['lib/graphql_ar.rb','lib/graphql_mutation.rb', 'lib/graphql_relation_helper.rb']
  s.add_runtime_dependency 'graphql'
  s.add_runtime_dependency 'activesupport'
end
