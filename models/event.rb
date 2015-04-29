module Comotion
  module Data
    module Event

      class Model < Struct.new(:location)
      end

      class Mapping
        def self.map
          {
            event: {
              properties: {
                id:         { type: 'string', store: 'true' },
                name:       { type: 'string', store: 'true' },
                place:      { type: 'string', store: 'true' },
                start_date: { type: 'date',   store: 'true' }, # TODO: add format
                end_date:   { type: 'date',   store: 'true' }, # TODO: add format
                pin: {
                  properties: {
                    location: { type: 'geo_point', store: 'true' },
                    color:    { type: 'string',    store: 'true' }
                  }
                },
                invited:   { type: 'string', store: 'true' },
                attending: { type: 'string', store: 'true' },
                tags:      { type: 'string', store: 'true' }
              }
            }
          }
        end
      end

    end
  end
end
