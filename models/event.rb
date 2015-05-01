module Comotion
  module Data
    module Event

      class Model < Struct.new(:id, :uid, :categories, :title, :description, :avatar, :start_time, :end_time, :location, :geo, :tags, :url)
      end

      class Mapping
        def self.map
          {
            event: {
              properties: {
                id:          { type: 'integer', store: 'true' },
                uid:         { type: 'string',  store: 'true' },
                title:       { type: 'string',  store: 'true' },
                description: { type: 'string',  store: 'true' },
                url:         { type: 'string',  store: 'true' },
                avatar:      { type: 'string',  store: 'true' },
                location:    { type: 'string', store: 'true' },
                start_time:  { type: 'date',   store: 'true', format: "yyyy-MM-dd'T'HH:mm:ssZ" }, # TODO: add format
                end_time:    { type: 'date',   store: 'true', format: "yyyy-MM-dd'T'HH:mm:ssZ" }, # TODO: add format
                pin: {
                  properties: {
                    coords:  { type: 'geo_point', store: 'true' },
                    color:   { type: 'string',    store: 'true' }
                  }
                },
                invited:   { type: 'string', store: 'true' },
                attending: { type: 'string', store: 'true' },
                tags:      { type: 'string', store: 'true', index: 'analyzed' }
              }
            }
          }
        end
      end

    end
  end
end
