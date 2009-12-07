require 'finder_form/attr'
module FinderForm
  module Attr
    class RangeAttrs < Base
      attr_reader :options
      def initialize(column, name, options)
        super(column, name)
        @options = options || {}
      end

      def setup
        range = options[:range] || {}
        min_def = range[:min] || options[:min] || {}
        max_def = range[:max] || options[:max] || {}
        min_attr = min_def[:attr] || "#{name}_min"
        max_attr = max_def[:attr] || "#{name}_max"
        client_class_eval("attr_accessor :#{min_attr}")
        client_class_eval("attr_accessor :#{max_attr}")
      end

    end
  end
end
