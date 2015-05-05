module Comotion
  module Data
    module Content

      class Model < Struct.new(:id)
      end

      class Mapping
        def self.map
          {
            content: {
              properties: {
                id:         { type: 'string',   store: true },
                type:       { type: 'string',   store: true },
                title:      { type: 'string',   store: true },
                content:    { type: 'string',   store: true },
                tags:       { type: 'string',   store: true },
                rating:     { type: 'integer',  store: true },
                created_by: { type: 'string',   store: true },
                created_at: { type: 'date',     store: true, format: "yyyy-MM-dd'T'HH:mm:ssZ" }
              }
            }
          }
        end
      end

    end
  end
end
