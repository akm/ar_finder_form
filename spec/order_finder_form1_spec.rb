# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'spec_helper')

class OrderFinderForm1
  include FinderForm

  def initialize(attrs = {})
    attrs.each{|key, value|send("#{key}=", value)}
  end

  with_model(Order) do
    # 静的なパラメータ
    column(:deleted_at, "IS NOT NULL")
    
    # belongs_to単数一致
    column(:user_id, :attr => :user_id)
    # belongs_toに使われているintegerはデフォルトでは一致と判断されます。
    
    # belongs_to複数一致
    column(:product_id, :attr => :product_ids, :operator => :IN)
    # :operatorが指定されているので、単数の一致ではなく複数のどれかへの一致になります
    
    # 範囲integer
    column(:amount)
    # belongs_toに使われていないintegerはデフォルトでは範囲と判断されます。
    # = column(:amount, :range => {:min => {:attr => :amount_min, :oprator => '>='}, :max => {:attr => :amount_max, :oprator => '<='}})
    
    # 範囲float
    column(:price)
    # dateはデフォルトでは範囲と判断されます。
    # => column_range(:price) 
    # column_rangeにはデフォルトで :minに'>='と:maxに'<='が指定されます。
    # = column(:price, :range => {:min => {:attr => :price_min, :oprator => '>='}, :max => {:attr => :price_max, :oprator => '<='}})
    
    # 範囲date
    column(:delivery_estimate)
    # dateはデフォルトでは範囲と判断されます。
    # => column_range(:delivery_estimate) 
    # column_rangeにはデフォルトで :minに'>='と:maxに'<='が指定されます。
    # => column_range(:delivery_estimate, :min => '>=', :max => '<=')
    
    # 範囲time
    column(:delivered_at)
    # timeはデフォルトでは範囲と判断されます。
    # => column_range(:delivered_at) 
    # column_rangeにはデフォルトで :minに'>='と:maxに'<='が指定されます。
    # => column_range(:delivered_at, :min => '>=', :max => '<=')
    
  end
end


describe OrderFinderForm1 do

  after do
    Order.find(:all, @form.to_find_options)
  end
  
  it "no attribute" do
    @form = OrderFinderForm1.new
    @form.to_find_options.should == {
      :conditions => "deleted_at IS NOT NULL"
    }
  end

  describe "belongs_to" do
    it "with integer" do
      @form = OrderFinderForm1.new(:user_id => 3)
      @form.to_find_options.should == {
        :conditions => ["deleted_at IS NOT NULL AND user_id = ?", 3]}
    end

    it "with string" do
      @form = OrderFinderForm1.new(:user_id => '3')
      @form.to_find_options.should == {
        :conditions => ["deleted_at IS NOT NULL AND user_id = ?", 3]}
    end
  end
  

  describe "belongs_to IN" do
    it "with integer array" do
      @form = OrderFinderForm1.new(:product_ids => [1,2,3,4])
      @form.to_find_options.should == {
        :conditions => ["deleted_at IS NOT NULL AND product_id IN (?)", [1,2,3,4]]}
    end
    
    it "with String array" do
      @form = OrderFinderForm1.new(:product_ids => %w(3 4 6 8))
      @form.to_find_options.should == {
        :conditions => ["deleted_at IS NOT NULL AND product_id IN (?)", [3, 4, 6, 8]]}
    end
    
    it "with comma separated string" do
      @form = OrderFinderForm1.new(:product_ids => '1,2,3,4')
      @form.to_find_options.should == {
        :conditions => ["deleted_at IS NOT NULL AND product_id IN (?)", [1,2,3,4]]}
    end
    
  end

  describe "integer range" do
    describe "as integer" do
      it "with min" do
        @form = OrderFinderForm1.new(:amount_min => 3)
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND amount >= ?", 3]}
      end

      it "with max" do
        @form = OrderFinderForm1.new(:amount_max => 10)
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND amount <= ?", 10]}
      end

      it "with min and max" do
        @form = OrderFinderForm1.new(:amount_min => 4, :amount_max => 9)
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND amount >= ? AND amount <= ?", 4, 9]}
      end
    end

    describe "as string" do
      it "with min" do
        @form = OrderFinderForm1.new(:amount_min => '3')
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND amount >= ?", 3]}
      end

      it "with max" do
        @form = OrderFinderForm1.new(:amount_max => '10')
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND amount <= ?", 10]}
      end

      it "with min and max" do
        @form = OrderFinderForm1.new(:amount_min => '4', :amount_max => '9')
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND amount >= ? AND amount <= ?", 4, 9]}
      end
    end
  end

  describe "float range" do
    describe "as float" do
      it "with min" do
        @form = OrderFinderForm1.new(:price_min => 3.9)
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND price >= ?", 3.9]}
      end

      it "with max" do
        @form = OrderFinderForm1.new(:price_max => 10.2)
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND price <= ?", 10.2]}
      end

      it "with comma separated string" do
        @form = OrderFinderForm1.new(:price_min => 4.1, :price_max => 9.9)
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND price >= ? AND price <= ?", 4.1, 9.9]}
      end
    end

    describe "as String" do
      it "with min" do
        @form = OrderFinderForm1.new(:price_min => '3.1')
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND price >= ?", 3.1]}
      end

      it "with max" do
        @form = OrderFinderForm1.new(:price_max => '10.1')
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND price <= ?", 10.1]}
      end

      it "with comma separated string" do
        @form = OrderFinderForm1.new(:price_min => 4.0, :price_max => 9.5)
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND price >= ? AND price <= ?", 4.0, 9.5]}
      end
    end
  end



  describe "date range" do
    describe "as Date" do
      it "with min" do
        @form = OrderFinderForm1.new(:delivery_estimate_min => Date.parse("2009/11/15"))
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND delivery_estimate >= ?", Date.parse("2009/11/15")]}
      end

      it "with max" do
        @form = OrderFinderForm1.new(:delivery_estimate_max => Date.parse("2009/11/15"))
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND delivery_estimate <= ?", Date.parse("2009/11/15")]}
      end

      it "with comma separated string" do
        @form = OrderFinderForm1.new(:delivery_estimate_min => Date.parse("2009/11/1"), :delivery_estimate_max => Date.parse("2009/11/15"))
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND delivery_estimate >= ? AND delivery_estimate <= ?", Date.parse("2009/11/1"), Date.parse("2009/11/15")]}
      end
    end

    describe "as DateTime" do
      it "with min" do
        @form = OrderFinderForm1.new(:delivery_estimate_min => DateTime.parse("2009/11/15 12:34:56"))
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND delivery_estimate >= ?", DateTime.parse("2009/11/15 12:34:56")]}
      end

      it "with max" do
        @form = OrderFinderForm1.new(:delivery_estimate_max => DateTime.parse("2009/11/15 01:02:03"))
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND delivery_estimate <= ?", DateTime.parse("2009/11/15 01:02:03")]}
      end

      it "with comma separated string" do
        @form = OrderFinderForm1.new(:delivery_estimate_min => DateTime.parse("2009/11/1 01:02:03"), :delivery_estimate_max => DateTime.parse("2009/11/15 11:32:33"))
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND delivery_estimate >= ? AND delivery_estimate <= ?", DateTime.parse("2009/11/1 01:02:03"), DateTime.parse("2009/11/15 11:32:33")]}
      end
    end

    describe "as String" do
      it "with min" do
        @form = OrderFinderForm1.new(:delivery_estimate_min => "2009-11-1")
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND delivery_estimate >= ?", Date.parse("2009/11/1")]}
      end

      it "with max" do
        @form = OrderFinderForm1.new(:delivery_estimate_max => "H21.11.15")
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND delivery_estimate <= ?", Date.parse("2009/11/15")]}
      end

      it "with comma separated string" do
        @form = OrderFinderForm1.new(:delivery_estimate_min => "2009/11/1", :delivery_estimate_max => "2009/11/15")
        @form.to_find_options.should == {
          :conditions => ["deleted_at IS NOT NULL AND delivery_estimate >= ? AND delivery_estimate <= ?", Date.parse("2009/11/1"), Date.parse("2009/11/15")]}
      end
    end
  end

  

  

end
