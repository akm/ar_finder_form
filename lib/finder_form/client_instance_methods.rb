require 'finder_form'
module FinderForm
  module ClientInstanceMethods
    UNBUILT_ATTRS.each do |attr_name|
      module_eval(<<-EOS)
        def #{attr_name}(value = nil)
          @#{attr_name} = value if value
          @#{attr_name} || self.class.#{attr_name}
        end
      EOS
    end

    def to_find_options(options = {})
      context = Context.build(self, options)
      context.to_find_options
    end

    def to_paginate_options(options = {})
      context = Context.build(self, options)
      context.to_paginate_options
    end

  end
end
