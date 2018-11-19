require 'her'
require 'chime_castle/ext/her'
require 'faraday_middleware'
require 'multi_json'
require 'openssl'
require 'net/http'
require 'request_store'
require 'active_support/core_ext/hash/indifferent_access'

require 'chime_castle/version'

require 'chime_castle/configuration'
require 'chime_castle/client'
require 'chime_castle/errors'
require 'chime_castle/utils'
require 'chime_castle/request'

require 'chime_castle/support/cookie_store'
require 'chime_castle/support/rails' if defined?(Rails::Railtie)
if defined?(Sinatra::Base)
  if defined?(Padrino)
    require 'chime_castle/support/padrino'
  else
    require 'chime_castle/support/sinatra'
  end
end

module ChimeCastle
  API = ChimeCastle.setup_api
end

# These need to be required after setting up Her
require 'chime_castle/models/model'
require 'chime_castle/models/account'
require 'chime_castle/models/event'
require 'chime_castle/models/location'
require 'chime_castle/models/user_agent'
require 'chime_castle/models/context'
require 'chime_castle/models/user'
require 'chime_castle/models/label'
require 'chime_castle/models/authentication'
