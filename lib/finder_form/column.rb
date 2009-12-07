require 'finder_form'
module FinderForm
  class Column
    attr_reader :table, :name, :options
    attr_reader :form_attr
    def initialize(table, name, *args)
      @table, @name = table, name
      @options = args.extract_options!
      @static_values = args.empty? ? nil : args
    end

    def setup
      send("setup_#{setup_type}")
    end

    def build(context)
      if @static_values
        context.add_condition(@static_values.map{|v| "#{table}.#{name} #{v}"}.
          join(' %s ' % (options[:connector] || 'AND')))
        return
      end
    end

    def static?
      !!@static_values
    end

    def foreign_key?
      table.model_class.reflections.
        any?{|name, ref| ref.primary_key_name == name}
    end

    def model_column
      result = table.model_column_for(name)
      unless result.is_a?(ActiveRecord::ConnectionAdapters::Column)
        raise "Unsupported column object for #{table.name}.#{name}: #{result.inspect}"
      end
      result
    end

    def type
      @options[:type] || model_column.type
    end

    private
    def setup_type
      return 'match_static' if static?
      return 'match_range' if options[:range]
      return "match_#{options[:match]}" if options[:match]
      case type
      when :string, :text then
        'match_partial'
      when :integer then
        foreign_key? ? 'match_exactly' : 'match_range'
      when :float, :datetime, :date, :time then
        'match_range'
      else
        'match_exactly'
      end
    end

    def setup_match_static
      nil
    end

    def setup_match_partial
      new_attr(Attr::Simple, {
        :operator => 'like'
      }.update(options))
    end

    def setup_match_exactly
      new_attr(Attr::Simple, {
        :operator => '='
      }.update(options))
    end

    def setup_match_range
      new_attr(Attr::RangeAttrs, options[:range])
    end

    def new_attr(klass, attr_options)
      @form_attr = klass.new(self, options[:attr] || name, attr_options)
      @form_attr.setup
      @form_attr
    end
   


  end
end
