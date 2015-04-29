require 'elasticsearch'
require 'pp'

Dir[File.expand_path('../../lib/**/*.rb', __FILE__)].each { |f| require f }
Dir[File.expand_path('../../models/*.rb', __FILE__)].each { |f| require f }

HOST  = 'localhost'
PORT  = 9200
INDEX = 'comotion'
TYPE = {
  'person' => Comotion::Data::Person,
  'event'  => Comotion::Data::Event,
  'group'  => Comotion::Data::Group
}

es = Elasticsearch::Client.new log:false

# Delete the old index
es.indices.delete(index: INDEX) if es.indices.exists(index: INDEX)
#es.indices.create index: INDEX

# Combine our mappings into one super-mapping
mapping = {mappings: {}}
TYPE.each do |k,v|
  mapping[:mappings].merge! v::Mapping.map
end

# Rebuild the index with the new mapping
es.indices.create index: INDEX, body: mapping
