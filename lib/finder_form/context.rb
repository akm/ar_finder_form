require 'finder_form'
module FinderForm
  class Context
    attr_reader :form, :options
    attr_reader :where, :params
    def initialize(form, options)
      @form, @options = form, options
      @where, @params = [], []
    end
    
    def add_condition(where, *params)
      @where << where
      @params.concat(params)
    end
    
    def to_find_options
      conditions = @where.join(" AND ")
      unless @params.empty?
        conditions = [conditions].concat(@params)
      end
      { 
        :conditions => conditions
      }
    end


  end
end
