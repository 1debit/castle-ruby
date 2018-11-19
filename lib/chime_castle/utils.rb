# TODO: scope Castle::Utils

module ChimeCastle
  class << self
    def setup_api(api_secret = nil)
      api_endpoint = ENV.fetch('CASTLE_API_ENDPOINT') {
        "https://api.castle.io/v1"
      }

      Her::API.setup url: api_endpoint do |c|
        c.use ChimeCastle::Request::Middleware::BasicAuth, api_secret
        c.use ChimeCastle::Request::Middleware::RequestErrorHandler
        c.use ChimeCastle::Request::Middleware::EnvironmentHeaders
        c.use ChimeCastle::Request::Middleware::ContextHeaders
        c.use FaradayMiddleware::EncodeJson
        c.use ChimeCastle::Request::Middleware::JSONParser
        c.use Faraday::Adapter::NetHttp
      end
    end
  end
end
