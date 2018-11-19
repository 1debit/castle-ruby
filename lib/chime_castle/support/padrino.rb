require_relative 'cookie_store'

module Padrino
  class Application
    module ChimeCastle
      module Helpers
        def castle
          @castle ||= ::ChimeCastle::Client.new(request, response)
        end
      end

      def self.registered(app)
        app.helpers Helpers
      end
    end

    register ChimeCastle
  end
end
