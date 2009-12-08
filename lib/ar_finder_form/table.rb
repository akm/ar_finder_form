require 'ar_finder_form'

class NameAccessableArray < Array
  attr_accessor :item_name
  def initialize(item_name, *args, &block)
    super(*args, &block)
    @item_name = item_name
  end

  def [](index_or_name)
    if index_or_name.is_a?(Integer)
      super.[](index_or_name)
    else
      detect{|item| name_for(item) == index_or_name}
    end
  end

  def name_for(item)
    item.send(item_name)
  end
end

module ArFinderForm
  class Table
    attr_reader :model_class, :columns, :joined_tables
    def initialize(model_class, *args)
      @model_class = model_class
      @columns = NameAccessableArray.new(:name)
      @joined_tables = []
    end

    def table_name; @model_class.table_name; end
    def name; table_name; end

    def column(column_name, *args)
      @columns << Column.new(self, column_name, *args)
    end

    def model_column_for(name)
      name = name.to_s
      @model_columns ||= @model_class.columns
      @model_columns.detect{|col| col.name.to_s == name}
    end

    def build_methods
      columns.each{|column| column.setup}
      joined_tables.each do |joined_table|
        joined_table.build_methods
      end
    end

    def build(context)
      columns.each{|column| column.build(context)}
      joined_tables.each do |joined_table|
        joined_table.build(context)
      end
    end

    def join(join_type, options, &block)
      join_as = options.delete(:as)
      join_on = options.delete(:on)
      ref_name = [:belongs_to, :has_one, :has_many].map{|k| options[k]}.compact.first
      raise ArgumentError, "#{join_type}_join requires :belongs_to, :has_one or :has_many" unless ref_name
      ref = @model_class.reflections[ref_name]
      raise ArgumentError, "no reflection for #{ref_name.inspect}" unless ref
      result = JoinedTable.new(self, join_type, ref)
      @joined_tables << result
      result.instance_eval(&block)
      result
    end

    JOIN_TYPES = (%w(inner cross natual) +
      %w(left right full).map{|t| [t, "#{t}_outer"]}.flatten).map(&:to_sym)

    JOIN_TYPES.each do |join_type|
      class_eval(<<-"EOS")
        def #{join_type.to_s}_join(options, &block)
          join(:#{join_type.to_s}, options, &block)
        end
      EOS
    end

  end
end
