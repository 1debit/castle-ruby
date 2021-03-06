# frozen_string_literal: true

module Castle
  module Utils
    class Merger
      def self.call(base, extra)
        base_s = Castle::Utils.deep_symbolize_keys(base)
        extra_s = Castle::Utils.deep_symbolize_keys(extra)

        extra_s.each do |name, value|
          if value.nil?
            base_s.delete(name)
          elsif value.is_a?(Hash) && base_s[name].is_a?(Hash)
            base_s[name] = call(base_s[name], value)
          else
            base_s[name] = value
          end
        end
        base_s
      end
    end
  end
end
