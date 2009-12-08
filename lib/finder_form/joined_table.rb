require 'finder_form'

module FinderForm
  class JoinedTable < Table
    attr_reader :reflection, :join_type, :parent_table
    def initialize(parent_table, join_type, reflection, *args)
      super(reflection.klass, *args)
      @parent_table = parent_table
      @join_type = join_type
      @reflection = reflection
      @table_name = reflection.klass.table_name
      @name = "cond_" << @table_name
    end

    def table_name; @table_name; end
    def name; @name; end

    def root_table
      parent_table.root_table
    end

    def build(context)
      sub_context = context.new_sub_context(:connector => 'AND')
      super(sub_context)
      unless sub_context.empty?
        context.merge(sub_context) do
          context.joins << build_join
        end
      end
    end

    def build_join
      join_on =
        case reflection.macro
        when :belongs_to then
          "#{name}.id = #{parent_table.name}.#{reflection.primary_key_name}"
        else
          "#{name}.#{reflection.primary_key_name} = #{parent_table.name}.id"
        end
      "%s JOIN %s %s ON %s" % [
        join_type.to_s.gsub(/\_/, ' ').upcase, reflection.klass.table_name, name, join_on
      ]
    end

  end
end
