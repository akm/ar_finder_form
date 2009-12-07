require 'finder_form/attr'
module FinderForm
  module Attr
    class Static < Base

      attr_reader :options
      attr_reader :values
      def initialize(column, name, values, options)
        super(column, name)
        @options = options
        @values = values || {}
      end

      def setup
        # do nothing
      end

      def build(context)
        context.add_condition(
          values.map{|v| "#{table.name}.#{column.name} #{v}"}.
          join(' %s ' % options[:connector]))
      end

    end
  end
end
