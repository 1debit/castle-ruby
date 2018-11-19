module ChimeCastle
  module CastleClient
    def castle
      @castle ||= env['castle'] || ChimeCastle::Client.new(request, response)
    end
  end

  ActiveSupport.on_load(:action_controller) do
    include CastleClient
  end
end
