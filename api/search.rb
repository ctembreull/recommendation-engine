module Comotion
  module Search
    class API < Grape::API

      namespace :search do

        params do
          optional :q, type: String
          optional :bucketed, type: Boolean, default: false
        end

        get do
          es = Comotion::Data::Elasticsearch.new
          eq = ::Esquire::CustomSearch.new(params[:q])
          eq.best_fields += ['tags', 'fullname', 'name', 'title', 'description', 'email', 'uwnetid']
          results = es.query(eq.build)

          if (params[:bucketed] == true)
            structured_results = { people: [], events: [], groups: [] }

            results['hits']['hits'].each do |hit|
              structured_results[:people] << hit if hit['_type'] == 'person'
              structured_results[:events] << hit if hit['_type'] == 'event'
              structured_results[:groups] << hit if hit['_type'] == 'group'
            end

            return structured_results
          else
            return results
          end
        end

        namespace :people do
          get do
            es = Comotion::Data::Elasticsearch.new('person')
            eq = ::Esquire::CustomSearch.new(params[:q])
            eq.best_fields += ['username', 'fullname', 'email', 'uwnetid', 'tags']

            results = es.query(eq.build)
          end
        end

        namespace :groups do
          get do
            es = Comotion::Data::Elasticsearch.new('group')
            eq = ::Esquire::CustomSearch.new(params[:q])
            eq.best_fields += ['name', 'description', 'tags']

            results = es.query(eq.build)
          end
        end

        namespace :events do

          params do
            requires :lat, type: Float
            requires :lon, type: Float
            requires :rad, type: Float
          end
          get :radius do
            es = Comotion::Data::Elasticsearch.new('event')
            eq = ::Esquire::EventSearch.new()
            eq.set_geometry(params[:lat], params[:lon], params[:rad])
            eq.set_future() # defaults to 7 days
            results = es.query(eq.build)
          end

          get do
            es = Comotion::Data::Elasticsearch.new('event')
            eq = ::Esquire::CustomSearch.new(params[:q])
            eq.best_fields += ['name']
          end

          params do
            requires :lat, type: Float
            requires :lon, type: Float
            optional :dst, type: Integer
          end
          get :nearby do
            es = Comotion::Data::Elasticsearch.new('event')
            eq = ::Esquire::GeoSearch.new(params[:q])
            eq.center(params[:lat], params[:lon])
            eq.radius(params[:dst])
            eq.best_fields += ['name']
          end

          params do
            optional :start_date, type: DateTime
            optional :end_date, type: DateTime
          end
          get :by_date do

          end
        end

        namespace :content do
          get do
            es = Comotion::Data::Elasticsearch.new('content')
            eq = ::Esquire::CustomSearch.new
            eq.best_fields += ['title', 'tags']
          end
        end

      end

    end
  end
end
