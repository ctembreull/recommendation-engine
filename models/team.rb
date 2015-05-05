module Comotion
  module Data
    module Team

      class Model < Struct.new(:id, :name, :description, :tags, :members, :seeking, :avatar, :url)
      end

      class Mapping
        def self.map
          {
            team: {
              properties: {
                id:          { type: String, store: true },
                name:        { type: String, store: true },
                description: { type: String, store: true },
                tags:        { type: String, store: true },
                members:     { type: String, store: true }, # members[]
                seeking:     { type: String, store: true },
                avatar:      { type: String, store: true },
                url:         { type: String, store: true },
              }
            }
          }
        end
      end

    end # module Event
  end # module Data
end # module Comotion
