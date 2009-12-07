require 'finder_form'
module FinderForm
  module ClientInstanceMethods
    def to_find_options(options = {})
      builder = self.class.builder
      context = Context.new(self, options)
      builder.build(context)
      context.to_find_options
    end

  end
end
