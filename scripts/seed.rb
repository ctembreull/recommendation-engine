require 'elasticsearch'

Dir[File.expand_path('../../lib/**/*.rb', __FILE__)].each { |f| require f }

HOST  = 'localhost'
PORT  = 9200
INDEX = 'comotion'
TYPE  = 'person'

es = Elasticsearch::Client.new log:false

mapping = Comotion::Data::Person.Mapping.map
# puts mapping

es.indices.delete(index: INDEX) if es.indices.exists(index: INDEX)
es.indices.create index: INDEX, type: 'user', body: Comotion::Data::Person.mapping

1000.times do
  user = Comotion::Data::Person.Stub.seed
  es.index index: INDEX, type: TYPE, id: user[:id], body: user
  # puts user
end
