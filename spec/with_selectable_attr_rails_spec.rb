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
    entry '1', :price, "金額" , :sql => 'orders.name desc'
    entry '2', :amount, "数量", :sql => 'orders.code desc'
    entry '3', :product_name, "商品名"    , :sql => 'products.name', :include => :product
    entry '4', :product_code, "商品コード", :sql => 'products.code', :include => :product
  end

  def after_build(context)
    context.find_options[:order] = self.order_entry[:sql]
  end

end

describe OrderFinderForm3 do


end

