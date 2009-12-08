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

  find_options(:order => "name asc")

  attr_accessor :order_expression
  def before_build(context)
    context.find_options[:order] = order_expression if order_expression
  end

  def after_build(context)
    if context.joins.any?{|join| join =~ /cond_products/}
      context.find_options[:order] = "#{context.find_options[:order]}, cond_products.code asc"
    end
  end
end


describe UserFinderForm1 do

  after do
    User.find(:all, @form.to_find_options)
  end

  it "no attribute" do
    @form = UserFinderForm1.new
    @form.to_find_options.should == {:order => "name asc"}
  end

  it "user_name" do
    @form = UserFinderForm1.new(:user_name => 'ABC')
    @form.to_find_options.should == {
      :order => "name asc",
      :conditions => ["users.name LIKE ?", '%ABC%']
    }
  end

  it "product_ids" do
    @form = UserFinderForm1.new(:product_ids => %w(1 3 7))
    @form.to_find_options.should == {
      :order => "name asc",
      :conditions => ["cond_orders.product_id IN (?)", [1,3,7]],
      :joins => "INNER JOIN orders cond_orders ON cond_orders.user_id = users.id"
    }
  end

  it "product_ids with custom order" do
    @form = UserFinderForm1.new(:product_ids => %w(1 3 7), :order_expression => "login desc")
    @form.to_find_options.should == {
      :order => "login desc",
      :conditions => ["cond_orders.product_id IN (?)", [1,3,7]],
      :joins => "INNER JOIN orders cond_orders ON cond_orders.user_id = users.id"
    }
  end

  it "product_name" do
    @form = UserFinderForm1.new(:product_name => "PPP")
    @form.to_find_options.should == {
      :order => "name asc, cond_products.code asc",
      :conditions => ["cond_products.name LIKE ?", "%PPP%"],
      :joins => "INNER JOIN orders cond_orders ON cond_orders.user_id = users.id" <<
        " INNER JOIN products cond_products ON cond_products.id = cond_orders.product_id"
    }
  end

  it "product_name" do
    @form = UserFinderForm1.new(:product_name => "PPP")
    @form.to_find_options.should == {
      :order => "name asc, cond_products.code asc",
      :conditions => ["cond_products.name LIKE ?", "%PPP%"],
      :joins => "INNER JOIN orders cond_orders ON cond_orders.user_id = users.id" <<
        " INNER JOIN products cond_products ON cond_products.id = cond_orders.product_id"
    }
  end

end
