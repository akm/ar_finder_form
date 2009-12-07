require 'finder_form/attr'
module FinderForm
  module Attr
    class Base
      attr_reader :column, :name, :options
      attr_reader :nil_available, :array_separator
      def initialize(column, name, options)
        @column, @name = column, name
        @nil_available = options.delete(:nil_available)
        @options = options
        @attr_filter = options[:attr_filter] || method(:column_type_cast)
        @array_separator = options.delete(:array_separator) || /[\s\,]/
      end
    
      def table; column.table; end
      def nil_available?; !!@nil_available; end

      def column_name(context)
        context.single_table? ? column.name : "#{table.name_for_column}.#{column.name}"
      end

      def client_class_eval(script, &block)
        klass = column.table.root_table.client_class
        klass.module_eval(&block) if block
        klass.module_eval(script) if script
      end

      def match?(context)
        nil_available? ? true : !!context.form.send(name)
      end

      def form_value(context)
        result = context.form.send(name)
        @attr_filter ? @attr_filter.call(result) : result
      end

      def form_value_array(context)
        values = context.form.send(name)
        values = values.to_s.split(array_separator) unless values.is_a?(Array)
        @attr_filter ? values.map{|v| @attr_filter.call(v)} : values
      end

      def column_type_cast(value)
        column.model_column.type_cast(value)
      end

    end
  end
end
