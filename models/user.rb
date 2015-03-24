module Comotion
  module Users

    class User

    end # class User


    class Entity

    end # class Entity

  end # module Users
end # module Comotion



module MyApp
  module User
    class Formatter

      def self.from_elasticsearch(result)
        data = []
        return data if result['hits'].empty? || result['hits'].nil?

        result['hits']['hits'].each do |doc|
          data << {
            id:    doc['_id'],
            score: doc['_score'],
            name:  doc['_source']['name']
          }
        end

        data
      end

    end
  end
end
