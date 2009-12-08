require 'ar_finder_form/attr'
module ArFinderForm
  module Attr
    class Simple < Base
      attr_reader :operator
      def initialize(column, name, options)
        super(column, name, options)
        @operator = options.delete(:operator).to_s.downcase.to_sym
      end

      def setup
        client_class_eval("attr_accessor :#{name}")
      end

      def build(context)
        return unless match?(context)
        case operator
        when :in then
          context.add_condition("#{column_name(context)} IN (?)",
            form_value_array(context))
        else
          context.add_condition(
            "#{column_name(context)} #{operator} ?",
            form_value(context))
        end
      end
    end
  end
end
