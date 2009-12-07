require 'finder_form'
module FinderForm
  module ClientInstanceMethods
    def to_find_options(options = {})
      builder = self.class.builder
      context = Context.new(self, options)
      context.order = self.order
      builder.build(context)
      context.to_find_options
    end

    def order(value = nil)
      @order = value if value
      @order || self.class.order
    end

  end
end
