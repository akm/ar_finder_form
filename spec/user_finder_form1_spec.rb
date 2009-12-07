# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'spec_helper')

class UserFinderForm1
  include FinderForm

  def initialize(attrs = {})
    attrs.each{|key, value|send("#{key}=", value)}
  end

  with_model(User) do
    column(:name, :attr => :user_name)
    inner_join(:has_many => :orders) do
      column(:product_id, :attr => :product_ids, :operator => :IN)
      inner_join(:belongs_to => :product) do
        column(:name, :attr => :product_name)
        column(:price)
      end
    end
    
  end
end


describe UserFinderForm1 do
  
  it "no attribute" do
    form1 = UserFinderForm1.new
    form1.to_find_options.should == {}
  end
  
  it "user_name" do
    form = UserFinderForm1.new(:user_name => 'ABC')
    form.to_find_options.should == {
      :conditions => ["users.name LIKE ?", '%ABC%']
    }
  end

  it "product_ids" do
    form = UserFinderForm1.new(:product_ids => %w(1 3 7))
    form.to_find_options.should == {
      :conditions => ["cond_orders.product_id IN (?)", [1,3,7]],
      :joins => "INNER JOIN orders cond_orders ON cond_orders.user_id = users.id"
    }
  end

  it "product_name" do
    form = UserFinderForm1.new(:product_name => "PPP")
    form.to_find_options.should == {
      :conditions => ["cond_products.name LIKE ?", "%PPP%"],
      :joins => "INNER JOIN orders cond_orders ON cond_orders.user_id = users.id" <<
        " INNER JOIN products cond_products ON cond_products.id = cond_orders.product_id"
    }
  end

end
