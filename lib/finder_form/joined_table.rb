require 'finder_form'

module FinderForm
  class JoinedTable < Table
    attr_reader :reflection, :join_type, :parent_table
    def initialize(parent_table, join_type, reflection, *args)
      super(reflection.klass, *args)
      @parent_table = parent_table
      @join_type = join_type
      @reflection = reflection
      @name_for_column = "cond_" << reflection.klass.table_name
    end
    
    def root_table
      parent_table.root_table
    end
    
    def build(context)
      sub_context = context.new_sub_context(:connector => 'AND')
      super(sub_context)
      if context.merge(sub_context)
        context.joins << build_join
      end
    end

    def build_join
      orgin_table = parent_table.model_class.table_name
      ref_table = reflection.klass.table_name
      join_on = 
        case reflection.macro
        when :belongs_to then
          "#{name_for_column}.id = #{orgin_table}.#{reflection.primary_key_name}"
        else
          "#{name_for_column}.#{reflection.primary_key_name} = #{orgin_table}.id"
        end
      "%s JOIN %s %s ON %s" % [
        join_type.to_s.gsub(/\_/, ' ').upcase, ref_table, name_for_column, join_on
      ]
    end

    def name_for_column
      @name_for_column
    end
    
  end
end
