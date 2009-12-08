require 'ar_finder_form'
module ArFinderForm
  module ClientInstanceMethods
    def find_options(value = nil)
      @find_options = value if value
      @find_options ||= self.class.find_options.dup
      @find_options
    end

    def paginate_options(value = nil)
      @find_options = value if value
      @find_options ||= self.class.paginate_options.dup
      @find_options
    end

    def to_find_options(options = {})
      context = Context.build(self, options)
      context.to_find_options
    end

    def to_paginate_options(options = {})
      context = Context.build(self, options)
      context.to_paginate_options
    end

    def find(*args)
      options = to_find_options(args.extract_options!)
      args << options
      self.class.builder.model_class.find(*args)
    end

    def paginate(*args)
      options = to_paginate_options(args.extract_options!)
      args << options
      self.class.builder.model_class.paginate(*args)
    end
  end
end
