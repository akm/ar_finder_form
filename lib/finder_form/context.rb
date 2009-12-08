require 'finder_form'
module FinderForm
  class Context
    attr_reader :form, :options, :joins
    attr_reader :where, :params
    attr_accessor :single_table
    
    UNBUILT_ATTRS.each{|attr_name| attr_accessor(attr_name)}

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

    def to_find_options(options = nil)
      conditions = @where.join(" %s " % @connector)
      unless @params.empty?
        conditions = [conditions].concat(@params)
      end
      result = {}
      result[:joins] = joins.join(' ') unless joins.empty?
      result[:conditions] = conditions unless conditions.empty?
      ATTRS_TO_FIND.each do |atr_name|
        value = send(atr_name)
        result[atr_name] = value unless value.blank?
      end
      options ? result.update(options) : result
    end

    def to_paginate_options(options = nil)
      result = to_find_options(options)
      ATTRS_TO_PAGINATE.each do |attr_name|
        value = send(attr_name)
        result[attr_name] = value unless value.blank?
      end
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

    def empty?
      to_find_options[:conditions].nil? && joins.empty?
    end

    def merge(sub_context)
      conditions = sub_context.to_find_options[:conditions]
      if conditions
        if conditions.is_a?(Array)
          add_condition(conditions.shift, *conditions)
        else
          add_condition(conditions)
        end
      end
      yield if block_given?
      unless sub_context.joins.empty?
        joins.concat(sub_context.joins)
      end
    end

    class << self
      def build(form, options)
        builder = form.class.builder
        context = Context.new(form, options)
        UNBUILT_ATTRS.each do |attr_name|
          context.send("#{attr_name}=", form.send(attr_name))
        end
        builder.build(context)
        context
      end
    end

  end
end
