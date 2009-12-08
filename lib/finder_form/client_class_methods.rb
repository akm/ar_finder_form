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

    def find_options(value = nil)
      @find_options = value if value
      @find_options ||= {}
    end

    def paginate_options(value = nil)
      @find_options = value if value
      @find_options ||= {}
    end

  end
end
