

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
            name:  doc['_source']['displayName'],
            email: doc['_source']['emails'][0]['value'],
            avatar: doc['_source']['thumbnailUrl']
          }
        end

        data
      end

    end
  end
end
