# typed: false
require 'crave'

module Crave::Support
  refine Hash do
    def stringify_keys
      Hash[*map{ |k,v| [k.to_s, v] }.flatten(1)]
    end
  end

  if !Array.instance_methods.include?(:to_h)
    refine Array do
      def to_h
        Hash[*flatten(1)]
      end
    end
  end
end
