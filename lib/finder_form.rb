# -*- coding: utf-8 -*-
module FinderForm
  ELEMENT_NAMES = %w(select order per_page)
  
  def self.included(mod)
    mod.module_eval do
      include ::SelectableAttr::Base
    end
    mod.extend(ClassMethods)
  end

  attr_accessor(*ELEMENT_NAMES)
  def attributes; @attributes ||= {}; end
  def joins; @joins ||= []; end
  def wheres; @wheres ||= []; end
  def parameters; @parameters ||= {}; end
  def conditions_operator; @conditions_operator ||= 'AND'; end

  def reset
    @build = false
    ELEMENT_NAMES.each do |element_name|
      self.send("#{element_name}=", nil)
    end
    self.joins = []
    self.wheres = []
    @attributes = {}
    @parameters = {}
  end
  
  def attributes_for(options = nil)
    result = @attributes || {}
    if options.nil? or options[:object_name].blank?
      result.dup
    else
      object_name = options[:object_name]
      result.inject({}) do |dest, entry|
        key, value = *entry
        dest["#{object_name}[#{key.to_s}]"] = value
        dest
      end
    end
  end
  
  def attributes=(attrs = {})
    self.class.elements.each{|element|element.update_finder(self, attrs)}
  end
  
  def build(base_context = {:element_names => ELEMENT_NAMES})
    self.class.elements.each{|element|element.process(self, base_context)}
    @build = true
  end
  
  def to_base_options(element_names, runtime_options, &block)
    build({:element_names => element_names}) unless @build
    result = {}
    where = self.wheres.compact.uniq.join(" #{conditions_operator} ")
    joins = self.joins.compact.uniq.join(' ').strip
    result[:conditions] = [where, parameters] unless where.blank?
    result[:joins] = joins unless joins.blank?
    element_names.each do |element_name|
      element_value = self.send(element_name)
      result[element_name.to_sym] = element_value unless element_value.blank?
    end
    result.update(runtime_options) if runtime_options
    result
  end
  
  def to_paginate_options(options = nil)
    to_base_options(ELEMENT_NAMES, options)
  end
  
  def to_find_options(options = nil)
    to_base_options(ELEMENT_NAMES - ['per_page'], options)
  end
  
  public
  
  class Element
    module Context
      def get(key, value_if_no_key = nil)
        if key?(key)
          value = self[key]
          return nil unless value
          value.respond_to?(:call) ? value.call(self) : value
        else
          value_if_no_key
        end
      end
      
      def catch_quit(&block)
        catch(:context_quit) do
          yield
        end
      end
      
      def quit
        throw :context_quit
      end
    end
    
    attr_reader :name, :options, :finder_class
    attr_reader :enum, :enum_array, :joins
    def initialize(name, klass, options)
      @name = name.to_sym
      @finder_class = klass
      @options = {
        :raw_value => method(:to_raw_value)
      }.update(options || {})
      if @enum = @options[:enum]
        @base_name = klass.enum_base_name(@name)
      end
    end
    
    def define_finder_attr
      default_value = @options.delete(:default)
      attr_name = self.name
      @finder_class.module_eval do
        if default_value
          attr_accessor_with_default(attr_name, default_value)
        else
          attr_accessor(attr_name)
        end
      end
    end
    
    def enum(*args, &block)
      if block_given?
        @enum = @finder_class.enum(@name, *args, &block)
        @base_name = @finder_class.enum_base_name(@name)
      else
        @enum
      end
    end
    
    def enum_array(*args, &block)
      if block_given?
        @enum_array = @finder_class.enum_array(@name, *args, &block)
        @base_name = @finder_class.enum_base_name(@name)
      else
        @enum_array
      end
    end
    
    def update_finder(attributes, finder)
      finder.send("#{self.name}=", attributes[self.name])
    end
    
    def process(finder, base_context)
      context = self.options.dup
      context.update(base_context)
      if @enum
        entry = finder.send("#{@base_name}_entry")
        context = context.update(entry.to_hash)
      end
      context[:element] = self
      context[:finder] = finder
      context.extend(Context)
      context.catch_quit do
        if self.options[:if].respond_to?(:call)
          result = self.options[:if].call(context)
          context.quit unless result
        end
        process_finder_value(context)
        process_conditions(context)
        process_joins(context)
        process_elements(context)
        process_attributes(context)
      end
    end
    
    def process_finder_value(context)
      raw_value = context.get(:raw_value)
      context[:raw_value] = raw_value
      context.quit if raw_value.nil? and !(context[:allow_nil] or context[:allow_blank])
      context.quit if raw_value.blank? and !context[:allow_blank]
      param_value = context.get(:param_value)
      context[:param_value] = param_value if param_value
    end
    
    def process_conditions(context, finder = context[:finder])
      conditions = context.get(:conditions)
      finder.wheres << conditions unless conditions.blank?
    end
    
    def process_joins(context, finder = context[:finder])
      tables = context[:tables]
      tables = tables.to_s.split(',') unless tables.is_a?(Array)
      tables << context[:table] unless context[:table].blank?
      joins = tables.map{|table|finder_class.joins_for_table(table)}
      joins << context[:joins] unless context[:joins].blank?
      result = joins.compact.uniq.join(' ')
      finder.joins << result if result
      result
    end
    
    def process_elements(context, finder = context[:finder])
      context[:element_names].each do |element_name|
        if name.to_s == element_name or
            ((process_for = context[:process_for]) and process_for.include?(element_name))
          element_value = context.get(element_name.to_sym)
          finder.send("#{element_name.to_s}=", element_value) unless element_value.blank?
        end
      end
    end

    def process_attributes(context, finder = context[:finder])
      finder.attributes[self.name] ||= context.get(:raw_value) # param_valueは使わない
    end
    
    def to_raw_value(context, finder = context[:finder])
      finder.send(self.name)
    end
  end
  
  class Parameter < Element
    attr_reader :column
    
    def initialize(name, klass, options)
      options = {
        :operator => '=',
        :param_value => method(:to_param_value),
        :conditions => method(:to_conditions)
      }.update(options || {})
      super(name, klass, options)
      @column = (@options[:column] || @name).to_s
      @column = '%s.%s' % [ @options[:table].to_s, @column] if @options[:table]
    end
    
    def process_conditions(context, finder = context[:finder])
      param_value = context.get(:param_value)
      where = context.get(:conditions)
      context.quit if where.blank?
      finder.wheres << where
      finder.parameters[name] = param_value if param_value
    end
    
    def to_conditions(context)
      return context[:conditions] if context[:conditions] and !context[:conditions].respond_to?(:call)
      operator = context.get(:operator)
      context[:conditions] = "#{column} #{operator} :#{name.to_s}"
    end
    
    def to_param_value(context)
      raise NoMethodError, "No implementation for #{self.class.name}#to_param_value(context)"
    end
    
    class Factory
      def self.create(name, finder_class, options = nil, &block)
        options ||= {}
        type = options.delete(:type) || :string
        factory = @factories[type.to_sym]
        raise ArgumentError, "Unsupported type: #{type.inspect}" unless factory
        factory.create(name, finder_class, options, &block)
      end
      
      def initialize(parameter_class, new_options = {})
        @parameter_class = parameter_class
        @new_options = new_options || {}
      end
      
      def create(name, finder_class, options, &block)
        options = @new_options.merge(options)
        args_array = arguments_array_for(name, finder_class, options)
        instances = args_array.map do |args|
          result = @parameter_class.new(*args)
          result.define_finder_attr
          result.instance_eval(&block) if block_given?
          result
        end
        instances.length == 1 ? instances.first : instances
      end
      
      def arguments_array_for(name, finder_class, options)
        if range_with = options.delete(:range_with)
          range_with = ['min', 'max'] if range_with == true
          range_with = range_with.to_s.split(',', 2) unless range_with.is_a?(Array)
          options[:column] ||= name
          options_min = {:operator => (options[:exclude_min] ? '>' : '>=')}.update(options)
          options_max = {:operator => (options[:exclude_max] ? '<' : '<=')}.update(options)
          args_min = ["#{name}_#{range_with.first.to_s}", finder_class, options_min]
          args_max = ["#{name}_#{range_with.last.to_s}", finder_class, options_max]
          return [args_min, args_max]
        else
          return [[name, finder_class, options]]
        end
      end

      def self.register(parameter_class, *type_names)
        options = type_names.extract_options!
        factory = new(parameter_class, options)
        @factories ||= {}
        type_names.each{|type_name|@factories[type_name] = factory}
      end
    end
    
    def self.register_as(*type_names)
      Factory.register(self, *type_names)
    end
    
    class IntegerParameter < Parameter
      register_as :integer
      def to_param_value(context, finder = context[:finder])
        context[:param_value] = context[:raw_value].to_i
      end
    end
    
    class StringParameter < Parameter
      register_as :string
      @@formatter_for_match = {
        :partial => '%%%s%%',
        :forward => '%s%%',
        :backward => '%%%s',
        :exact => '%s'
      }
      @@operator_for_match = {
        :partial => 'like',
        :forward => 'like',
        :backward => 'like',
        :exact => '='
      }
      
      def initialize(name, klass, options)
        super(name, klass, {
            :match => :partial,
            :operator => method(:to_operator)
          }.update(options || {}))
      end
      
      def to_param_value(context, finder = context[:finder])
        formatter = @@formatter_for_match[context[:match]]
        context[:param_value] = formatter % context[:raw_value]
      end
      
      def to_operator(context)
        @@operator_for_match[context[:match]]
      end
    end
    
    class DateTimeParameter < Parameter
      register_as :time, :parser => Time
      register_as :date, :parser => Date
      register_as :datetime, :parser => DateTime
      
      def to_param_value(context, finder = context[:finder])
        value = context[:raw_value]
        context[:param_value] = value.blank? ? nil : 
          (value.is_a?(Date) or value.is_a?(Time)) ? value :
          context.get(:parser).parse(value.to_s)
      end
    end
    
    class ArrayParameter < Parameter
      register_as :string_array, :strings, :value_convertor => :to_s
      register_as :integer_array, :integers, :value_convertor => :to_i

      def initialize(name, klass, options)
        super(name, klass, {:operator => 'in', :delimeter => ','}.update(options || {}))
      end
      
      def to_conditions(context)
        operator = context.get(:operator)
        result = "#{column} #{operator} (:#{name.to_s})"
        result
      end

      def to_param_value(context, finder = context[:finder])
        value = context[:raw_value]
        unless value.is_a?(Array)
          delimeter = context.get(:delimeter)
          value = value.to_s.split(delimeter)
        end
        convertor = context[:value_convertor]
        context[:param_value] = value.empty? ? nil : 
          convertor ? value.map(&convertor) : value
        result = context[:param_value]
        finder.send("#{name}=", result)
        result
      end
    end
  end
  
  module ClassMethods
    def elements
      @elements ||= []
    end
    
    def element(element_name, string_or_enum_options = nil, &block)
      if block_given?
        element = Element.new(element_name, self,
          string_or_enum_options || {})
        element.define_finder_attr
        element.instance_eval(&block) if block_given?
        self.elements << element
      elsif string_or_enum_options
        # 
      else
        self.send(element_name)
      end
    end
    
    def order(string_or_enum_options = nil, &block)
      if block_given?
        string_or_enum_options = {
          :process_for => ['order']
        }.update(string_or_enum_options || {})
      end
      element(:order_cd, string_or_enum_options, &block)
    end

    def per_page(string_or_enum_options = nil, &block)
      if block_given?
        string_or_enum_options = {
          :per_page => proc{|context|
            value = context.get(:raw_value)
            value = value ? value.to_i : nil
            context[:finder].send("per_page=", value)
            context[:per_page] = context[:raw_value] = value
          }
        }.update(string_or_enum_options || {})
      end
      element(:per_page, string_or_enum_options, &block)
    end

    def parameter(*args, &block)
      options = {:type => :string}
      options.update(@with_options) if @with_options
      options.update(args.pop) if args.last.is_a?(Hash)
      args.each do |arg|
        parameters = Parameter::Factory.create(arg, self, options, &block)
        if parameters.is_a?(Array)
          parameters.each{|parameter|self.elements << parameter}
        else
          self.elements << parameters
        end
      end
    end
    
    def with(options, &block)
      backup_with_options = @with_options
      begin
        @with_options = (backup_with_options || {}).merge(options || {})
        remember_table_and_join(@with_options)
        yield
      ensure
        @with_options = backup_with_options
      end
    end

    def table(table_name, options = nil, &block)
      with({:table => table_name}.merge(options || {}), &block)
    end
    
    private
    def with_join(join_type, *names, &block)
      names.compact!
      if names.length == 2
        table_name, options = *names
      elsif names.length == 3
        table_name, alias_name, options = *names
      else
        raise ArgumentError, '%s needs (table_name, [alias_name,] [:on => "...",][:using => "..."])' % join_type
      end
      join_on = options.delete(:on)
      using = options.delete(:using)
      # raise ArgumentError, 'join needs :on or :using' unless join_on || using
      join_value = "#{join_type} #{table_name}"
      join_value << alias_name if alias_name
      join_value << " on #{join_on}" if join_on
      join_value << " using #{using}" if using
      table(alias_name || table_name, {:joins => join_value}.update(options || {}), &block)
    end
    
    public
    JOIN_TYPES = %w(join inner_join left_join left_outer_join right_join right_outer_join cross_join)

    JOIN_TYPES.each do |join_type|
      join_str = join_type.gsub('_', ' ')
      self.module_eval(<<-"EOS")
        def #{join_type}(*names, &block)
          with_join('#{join_str}', *names, &block)
        end
      EOS
    end
    
    def remember_table_and_join(options)
      table = options[:table]
      joins = options[:joins]
      return unless table and joins
      @joins_for_table ||= {}
      @joins_for_table[table.to_s] = joins
    end
    
    def joins_for_table(table)
      @joins_for_table[table.to_s] if @joins_for_table
    end
  end
  
  class Base
    include ::FinderForm
    
    def initialize(attrs = nil)
      (attrs || {}).each{|k,v|self.send("#{k.to_s}=", v)}
    end
  end
end
