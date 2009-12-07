require 'finder_form/attr'
module FinderForm
  module Attr
    class Base
      attr_reader :column, :name
      def initialize(column, name)
        @column, @name = column, name
      end
    
      def client_class_eval(script, &block)
        puts "#{self.class.name}#client_class_eval(#{script})"
        klass = column.table.root_table.client_class
        klass.module_eval(&block) if block
        klass.module_eval(script) if script
      end

    end
  end
end
