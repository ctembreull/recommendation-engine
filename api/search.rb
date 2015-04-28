module Comotion
  module Search
    class API < Grape::API

      namespace :search do

        params do
          optional :q, type: String
        end

        get do
          es = Comotion::Data::Elasticsearch.new
        end

        namespace :people do
          get do
            es = Comotion::Data::Elasticsearch.new('person')
            eq = ::Esquire::CustomSearch.new(params[:q])
            eq.best_fields += ['username', 'fullname', 'email', 'uwnetid', 'tags']
          end
        end

        namespace :events do
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
