require 'ar_finder_form/attr'
module ArFinderForm
  module Attr
    class Static < Base

      attr_reader :values
      def initialize(column, name, values, options)
        super(column, name, options)
        @values = values || {}
      end

      def setup
        # do nothing
      end

      def build(context)
        context.add_condition(
          values.map{|v| "#{column_name(context)} #{v}"}.
          join(' %s ' % options[:connector]))
      end

    end
  end
end
