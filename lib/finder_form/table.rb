require 'finder_form'

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

module FinderForm
  class Table
    attr_reader :model_class, :columns
    def initialize(model_class, *args)
      @model_class = model_class
      @columns = NameAccessableArray.new(:name)
    end
    
    def name
      @model_class.table_name
    end

    def column(column_name, *args)
      @columns << Column.new(self, column_name, *args)
    end

    def model_column_for(name)
      name = name.to_s
      @model_columns ||= @model_class.columns
      @model_columns.detect{|col| col.name.to_s == name}
    end

    def root_table
      self
    end


  end
end
