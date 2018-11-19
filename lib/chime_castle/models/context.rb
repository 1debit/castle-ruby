module ChimeCastle
  class Context < Model
    def user_agent
      if attributes['user_agent']
        ChimeCastle::UserAgent.new(attributes['user_agent'])
      end
    end

    def location
      if attributes['location']
        ChimeCastle::Location.new(attributes['location'])
      end
    end
  end
end
