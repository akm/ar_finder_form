require 'finder_form'

module FinderForm
  class Builder < Table
    attr_reader :client_class, :model_class
    attr_reader :columns
    def initialize(client_class, model_class)
      super(model_class)
      @client_class = client_class
    end
    
    def build_methods
      columns.each do |column|
        column.setup
#        attr_name = column.options[:attr] || column.name
#        @client_class.module_eval("attr_accessor :#{attr_name}")
      end
    end
    
    def build(context)
      columns.each do |column|
        column.build(context)
      end
    end

  end
end
