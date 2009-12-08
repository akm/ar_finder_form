# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'spec_helper')

class OrderFinderForm3
  include FinderForm
  include SelectableAttr::Base

  def initialize(attrs = {})
    attrs.each{|key, value|send("#{key}=", value)}
  end
  
  with_model(Order) do
    column(:price)
    column(:amount)
    
    inner_join(:belongs_to => :product) do
      column(:name, :attr => :product_name)
      column(:code, :attr => :product_code)
    end
  end

  selectable_attr :order_cd, :default => '1' do
    entry '1', :price, "金額" , :order => 'orders.price desc'
    entry '2', :amount, "数量", :order => 'orders.amount desc'
    entry '3', :product_name, "商品名"    , :order => 'products.name asc', :include => :product
    entry '4', :product_code, "商品コード", :order => 'products.code asc', :include => :product
  end

  selectable_attr :per_page_count, :default => '10' do
    [10, 20, 50, 100].each do |cnt|
      entry cnt.to_s, cnt.to_s.to_sym, "#{cnt} records"
    end
  end

  def after_build(context)
    context.paginate_options[:per_page] = self.per_page_count.to_i
    return if self.order_entry.null?
    context.find_options.update(self.order_entry.instance_variable_get(:@options) || {})
  end

end

describe OrderFinderForm3 do
  it "default" do
    @form = OrderFinderForm3.new
    @form.to_find_options.should == {:order => "orders.price desc"}
    @form.to_paginate_options(:page => 5).should == {
      :per_page => 10, :page => 5
    }.update(@form.to_find_options)
  end

  it "default" do
    @form = OrderFinderForm3.new(:product_name => "ABC", :order_key => :product_name, :per_page_count => '50')
    @form.to_find_options.should == {
      :order => "products.name asc",
      :conditions => ["cond_products.name LIKE ?", '%ABC%'],
      :joins=>"INNER JOIN products cond_products ON cond_products.id = orders.product_id",
      :include => :product
    }
    @form.to_paginate_options(:page => 6).should == {
      :per_page => 50, :page => 6
    }.update(@form.to_find_options)
  end
  
end

