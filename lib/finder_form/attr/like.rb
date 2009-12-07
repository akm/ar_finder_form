require 'finder_form/attr'
module FinderForm
  module Attr
    class Like < Base

      MATCHERS = {
        :forward => '%s%%',
        :backward => '%%%s',
        :partial => '%%%s%%'
      }

      attr_reader :operator
      def initialize(column, name, options)
        super(column, name, options)
        @mathcer = MATCHERS[options[:match]] || MATCHERS[:partial]
      end

      def setup
        client_class_eval("attr_accessor :#{name}")
      end

      def build(context)
        return unless match?(context)
        context.add_condition(
          "#{column_name(context)} LIKE ?",
          @mathcer % form_value(context).to_s)
      end
    end
  end
end
