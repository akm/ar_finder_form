require 'finder_form/attr'
module FinderForm
  module Attr
    class Simple < Base
      attr_reader :options
      def initialize(column, name, options)
        super(column, name)
        @options = options || {}
      end

      def setup
        client_class_eval("attr_accessor :#{name}")
      end

    end
  end
end
