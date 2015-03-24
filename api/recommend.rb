module Comotion
  # Recommends things, duh.
  class Recommendations < Grape::API

    namespace :recommendations do

      get :test do
        esq = Esquire::UserRecommendation.new
        esq.interests = ['business', 'strategy', 'accounting']
        MyApp::User::Formatter.from_elasticsearch(esq.run)
      end

      params do
        optional :roles,     type: Array
        requires :interests, type: Array
        optional :following, type: Array
        optional :count,     type: Integer, default: 25
        optional :debug,     type: Boolean, default: false
      end
      post :follows do
        esq = Esquire::UserRecommendation.new
        esq.roles     = params[:roles] unless params[:roles].nil?
        esq.interests = params[:interests]

        results = MyApp::User::Formatter.from_elasticsearch(esq.run)

        if params[:debug]
          return { query: esq.build, results: results }
        else
          return results
        end
      end

    end

  end
end
