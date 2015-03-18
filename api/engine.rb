module MyApp
  # Control surface for Elasticsearch
  class Engine < Grape::API

    params do
      optional :pool, type: Integer, default: 1000
    end
    post :seed do
      interests = MyApp::Interests.list_all
      params[:pool].times do

      end
    end

  end
end
