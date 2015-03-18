module MyApp
  # Default runnable for Rack
  class App
    def initialize; end

    # TODO: replace MyApp with your module structure
    def self.instance
      @instance ||= Rack::Builder.new(debug: true) do
        run MyApp::App.new
      end.to_app
    end

    # TODO: replace MyApp with your module structure
    def call(env)
      MyApp::API.call(env)
    end
  end
end
