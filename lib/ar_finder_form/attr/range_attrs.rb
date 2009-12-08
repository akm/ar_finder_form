require 'ar_finder_form/attr'
module ArFinderForm
  module Attr
    class RangeAttrs < Base

      attr_accessor :min, :max
      def initialize(column, name, options)
        super(column, name, options)
        range = options[:range] || {}
        min_def = {:operator => '>='}.update(range[:min] || options[:min] || {})
        max_def = {:operator => '<='}.update(range[:max] || options[:max] || {})
        @min = Simple.new(column, min_def[:attr] || "#{name}_min", min_def)
        @max = Simple.new(column, max_def[:attr] || "#{name}_max", max_def)
      end

      def setup
        @min.setup
        @max.setup
      end

      def build(context)
        sub_context = context.new_sub_context(:connector => 'AND')
        @min.build(sub_context)
        @max.build(sub_context)
        context.merge(sub_context)
      end
    end
  end
end
