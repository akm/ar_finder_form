require 'finder_form'
module FinderForm
  module ClientClassMethods
    attr_reader :builder
    def with_model(model_class, &block)
      @builder = Builder.new(self, model_class)
      @builder.instance_eval(&block)
      @builder.build_methods
      @builder
    end

    UNBUILT_ATTRS.each do |attr_name|
      module_eval(<<-EOS)
        def #{attr_name}(value = nil)
          @#{attr_name} = value if value
          @#{attr_name}
        end
      EOS
    end

  end
end
