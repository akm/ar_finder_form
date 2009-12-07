require 'finder_form'
module FinderForm
  class Context
    attr_reader :form, :options, :joins
    attr_reader :where, :params
    attr_accessor :single_table
    def initialize(form, options = {})
      @form, @options = form, options
      @where, @params = [], []
      @joins = []
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
      result[:joins] = joins.join(' ') unless joins.empty?
      result[:conditions] = conditions unless conditions.empty?
      result
    end

    def single_table?
      @single_table
    end

    def new_sub_context(options = {})
      result = Context.new(form, options)
      result.single_table = self.single_table
      result
    end
    
    def merge(sub_context)
      conditions = sub_context.to_find_options[:conditions]
      return nil unless conditions
      if conditions.is_a?(Array)
        add_condition(conditions.shift, *conditions)
      else
        add_condition(conditions)
      end
      true
    end

  end
end
