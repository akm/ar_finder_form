require 'finder_form'

module FinderForm
  class Builder < Table
    attr_reader :client_class, :model_class
    attr_reader :columns
    def initialize(client_class, model_class)
      super(model_class)
      @client_class = client_class
    end
    
    def root_table
      self
    end
    
    def build(context)
      context.single_table = joined_tables.empty?
      form = context.form
      form.send(:before_build, context) if form.respond_to?(:before_build)
      super(context)
      form.send(:after_build, context) if form.respond_to?(:after_build)
    end

  end
end
