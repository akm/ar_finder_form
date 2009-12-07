require 'finder_form/attr'
module FinderForm
  module Attr
    class Base
      attr_reader :column, :name
      def initialize(column, name)
        @column, @name = column, name
        # puts "#{table.name}.#{column.name} => #{self.class.name} : #{@name}"
      end
    
      def table; column.table; end

      def client_class_eval(script, &block)
        klass = column.table.root_table.client_class
        klass.module_eval(&block) if block
        klass.module_eval(script) if script
      end

    end
  end
end
