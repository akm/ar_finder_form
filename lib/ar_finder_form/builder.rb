require 'ar_finder_form'

module ArFinderForm
  class Builder < Table
    attr_reader :client_class, :model_class
    attr_reader :columns
    def initialize(client_class, model_class)
      super(model_class)
      @client_class = client_class
    end

    def root_table
      self
    end

    def build(context)
      context.single_table = joined_tables.empty?
      super(context)
    end

  end
end
