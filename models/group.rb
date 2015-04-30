module Comotion
  module Data
    module Group

      class Model < Struct.new(:id, :name, :description, :join_policy, :created_at, :tags, :website, :avatar, :url)
      end

      class Mapping
        def self.map
          {
            group: {
              properties: {
                id:          { type: 'string',  store: true },
                name:        { type: 'string',  store: true },
                description: { type: 'string',  store: true },
                join_policy: { type: 'integer', store: true },
                created_at:  { type: 'date',    store: true }, # TODO: add format
                tags:        { type: 'string',  store: true },
                website:     { type: 'string',  store: true },
                avatar:      { type: 'string',  store: true },
                url:         { type: 'string',  store: true },
              }
            }
          }
        end
      end

    end # module Group
  end # module Data
end # module Comotion
