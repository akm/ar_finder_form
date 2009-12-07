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

  end
end