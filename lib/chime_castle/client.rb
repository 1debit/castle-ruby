module ChimeCastle
  class Client

    attr_accessor :request_context, :do_not_track

    def initialize(request, response, opts = {})
      # Save a reference in the per-request store so that the request
      # middleware in request.rb can access it
      RequestStore.store[:chime_castle] = self

      @request_context = {
        ip: request.ip,
        user_agent: request.user_agent,
        cookie_id: extract_cookies(request, response)['__cid'] || '',
        headers: header_string(request)
      }
    end

    def identify(user_id, opts = {})
      return if @do_not_track
      ChimeCastle::User.save_existing(user_id, opts)
    end

    def track(opts = {})
      return if @do_not_track
      ChimeCastle::Event.create(opts)
    end

    def do_not_track!
      @do_not_track = true
    end

    def track!
      @do_not_track = false
    end

    def authenticate(user_id)
      ChimeCastle::Authentication.create(user_id: user_id)
    end

    def authentication(authentication_id)
      ChimeCastle::Authentication.find(authentication_id)
    end

    def authentications
      ChimeCastle::Authentication
    end

    private

    def extract_cookies(request, response)
      # Extract the cookie set by the ChimeCastle Javascript
      if response.class.name == 'ActionDispatch::Cookies::CookieJar'
        ChimeCastle::CookieStore::Rack.new(response)
      else
        ChimeCastle::CookieStore::Base.new(request, response)
      end
    end

    # Serialize HTTP headers
    def header_string(request)
      scrub_headers = ['Cookie']

      headers = request.env.keys.grep(/^HTTP_/).map do |header|
        name = header.gsub(/^HTTP_/, '').split('_').map(&:capitalize).join('-')
        unless scrub_headers.include?(name)
          { name => request.env[header] }
        end
      end.compact.inject(:merge)

      MultiJson.encode(headers)
    end
  end
end
