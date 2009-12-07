require 'finder_form'
module FinderForm
  class Context
    attr_reader :form, :options
    attr_reader :where, :params
    def initialize(form, options = {})
      @form, @options = form, options
      @where, @params = [], []
      @connector = options.delete(:connector) || 'AND'
    end
    
    def add_condition(where, *params)
      @where << where
      @params.concat(params)
    end
    
    def to_find_options
      conditions = @where.join(" %s " % @connector)
      unless @params.empty?
        conditions = [conditions].concat(@params)
      end
      result = {}
      result[:conditions] = conditions unless conditions.empty?
      result
    end

    def single_table?
      true
    end

    def new_sub_context(options = {})
      Context.new(form, options)
    end

  end
end
