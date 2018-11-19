module ChimeCastle
  module Request

    def self.client_user_agent
      @uname ||= get_uname
      lang_version = "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})"

      {
        :bindings_version => ChimeCastle::VERSION,
        :lang => 'ruby',
        :lang_version => lang_version,
        :platform => RUBY_PLATFORM,
        :publisher => 'castle',
        :uname => @uname
      }
    end

    def self.get_uname
      `uname -a 2>/dev/null`.strip if RUBY_PLATFORM =~ /linux|darwin/i
    rescue Errno::ENOMEM # couldn't create subprocess
      "uname lookup failed"
    end

    #
    # Faraday middleware
    #
    module Middleware
      # Sets credentials dynamically, allowing them to change between requests.
      #
      class BasicAuth < Faraday::Middleware
        def initialize(app, api_secret)
          super(app)
          @api_secret = api_secret
        end

        def call(env)
          value = Base64.encode64(":#{@api_secret || ChimeCastle.config.api_secret}")
          value.delete!("\n")
          env[:request_headers]["Authorization"] = "Basic #{value}"
          @app.call(env)
        end
      end

      # Handle request errors
      #
      class RequestErrorHandler < Faraday::Middleware
        def call(env)
          env.request.timeout = ChimeCastle.config.request_timeout
          begin
            @app.call(env)
          rescue Faraday::ConnectionFailed
            raise ChimeCastle::RequestError, 'Could not connect to Castle API'
          rescue Faraday::TimeoutError
            raise ChimeCastle::RequestError, 'Castle API timed out'
          end
        end
      end

      # Adds details about current environment
      #
      class EnvironmentHeaders < Faraday::Middleware
        def call(env)
          begin
            env[:request_headers]["X-Castle-Client-User-Agent"] =
              MultiJson.encode(ChimeCastle::Request.client_user_agent)
          rescue # ignored
          end

          if ChimeCastle.config.source_header
            env[:request_headers]["X-Castle-Source"] =
              ChimeCastle.config.source_header
          end

          env[:request_headers]["User-Agent"] =
            "Castle/v1 RubyBindings/#{ChimeCastle::VERSION}"

          @app.call(env)
        end
      end

      # Adds request context like IP address and user agent to any request.
      #
      class ContextHeaders < Faraday::Middleware
        def call(env)
          castle = RequestStore.store[:chime_castle]
          return @app.call(env) unless castle

          castle.request_context.each do |key, value|
            if value
             header =
              "X-Castle-#{key.to_s.gsub('_', '-').gsub(/\w+/) {|m| m.capitalize}}"
              env[:request_headers][header] = value
            end
          end
          @app.call(env)
        end
      end

      class JSONParser < Faraday::Response::Middleware
        def on_complete(env)
          response = if env[:body].nil? || env[:body].empty?
            {}
          else
            begin
              MultiJson.load(env[:body], :symbolize_keys => true)
            rescue MultiJson::LoadError
              raise ChimeCastle::ApiError, 'Invalid response from Castle API'
            end
          end

          case env[:status]
          when 200..299
            # OK
          when 400
            raise ChimeCastle::BadRequestError, response[:message]
          when 401
            raise ChimeCastle::UnauthorizedError, response[:message]
          when 403
            raise ChimeCastle::ForbiddenError, response[:message]
          when 404
            raise ChimeCastle::NotFoundError, response[:message]
          when 419
            # session token is invalid so clear it
            RequestStore.store[:chime_castle].session_token = nil

            raise ChimeCastle::UserUnauthorizedError, response[:message]
          when 422
            raise ChimeCastle::InvalidParametersError, response[:message]
          else
            raise ChimeCastle::ApiError, response[:message]
          end

          env[:body] = {
            data: response,
            metadata: [],
            errors: {}
          }
        end
      end

    end

  end
end
