# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'spec_helper')

class OrderFinderFormForTable
  include FinderForm

  with_model(Order) do
  end

end


describe FinderForm::Table do

  before do
    @table = OrderFinderFormForTable.builder
  end

  it "name" do
    @table.name.should == "orders"
  end

  it "root_table" do
    @table.root_table.should == @table
  end

  describe "model_column_for" do
    column_names = [:id, :user_id, :product_id, :amount, :price, 
      :delivery_estimate, :delivered_at, :deleted_at]

    it "by Symbol" do
      column_names.each do |column_name|
        @table.model_column_for(column_name).should be_ar_column(column_name.to_s)
      end
      @table.model_column_for('unexist_column').should be_nil
    end

    it "by String" do
      column_names.each do |column_name|
        @table.model_column_for(column_name.to_s).should be_ar_column(column_name.to_s)
      end
      @table.model_column_for(:unexist_column).should be_nil
    end
    
  end
  

end
