# frozen_string_literal: true

module Castle
  module Extractors
    # used for extraction of ip from the request
    class IP
      def initialize(request)
        @request = request
      end

      def call
        return @request.env['HTTP_CF_CONNECTING_IP'] if @request.env['HTTP_CF_CONNECTING_IP']
        return @request.remote_ip if @request.respond_to?(:remote_ip)
        @request.ip
      end
    end
  end
end
