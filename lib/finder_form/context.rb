require 'finder_form'
module FinderForm
  class Context
    FIND_OPTIONS_KEYS = [:order, :group, :limit, :offset, :include, 
      :select, :from, :readonly, :lock
    ]
    PAGINATE_OPTIONS_KEYS = [:per_page, :page, :total_entries, :count, :finder]

    attr_reader :form, :options, :joins
    attr_reader :where, :params
    attr_accessor :single_table
    
    def initialize(form, options = {})
      @form, @options = form, options
      @where, @params = [], []
      @joins = []
      @connector = options.delete(:connector) || 'AND'
      FIND_OPTIONS_KEYS.each do |attr_name|
        if value = @options[attr_name]
          @find_options ||= {}
          @find_options[attr_name] = value
        end
      end
      PAGINATE_OPTIONS_KEYS.each do |attr_name|
        if value = @options[attr_name]
          @paginate_options ||= {}
          @paginate_options[attr_name] = value
        end
      end
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
      if find_options
        FIND_OPTIONS_KEYS.each do |attr_name|
          value = find_options[attr_name]
          result[attr_name] = value unless value.blank?
        end
      end
      result[:joins] = joins.join(' ') unless joins.empty?
      result[:conditions] = conditions unless conditions.empty?
      options ? result.update(options) : result
    end

    def to_paginate_options(options = nil)
      result = to_find_options(options)
      if paginate_options
        PAGINATE_OPTIONS_KEYS.each do |attr_name|
          value = paginate_options[attr_name]
          result[attr_name] = value unless value.blank?
        end
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

    def build(builder)
      form.send(:before_build, self) if form.respond_to?(:before_build)
      builder.build(self)
      form.send(:after_build, self) if form.respond_to?(:after_build)
    end

    def find_options; @find_options ||= {}; end
    def paginate_options; @paginate_options ||= {}; end

    class << self
      def build(form, options)
        builder = form.class.builder
        options = 
          (form.find_options || {}).dup.
          update(form.find_options || {}).
          update(options || {})
        context = Context.new(form, options)
        context.build(builder)
        context
      end
    end

  end
end
