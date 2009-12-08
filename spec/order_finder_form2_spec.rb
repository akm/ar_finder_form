# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'spec_helper')

class OrderFinderForm2
  include FinderForm

  def initialize(attrs = {})
    attrs.each{|key, value|send("#{key}=", value)}
  end

  with_model(Order) do
    # joins
    inner_join(:belongs_to => :user) do
      # like
      column(:name, :attr => :user_name1)
      # like forward
      column(:name, :attr => :user_name2, :match => :forward)
      # like backward
      column(:name, :attr => :user_name3, :match => :backward)
    end
  end

  per_page(50)
end


describe OrderFinderForm2 do
  
  after do
    Order.find(:all, @form.to_find_options)
    @form.find(:all)
  end  

  it "no attribute" do
    @form = OrderFinderForm2.new
    @form.to_find_options.should == {}
  end
  
  it "user_name1" do
    @form = OrderFinderForm2.new(:user_name1 => 'ABC')
    @form.to_find_options.should == {
      :conditions => ["cond_users.name LIKE ?", '%ABC%'],
      :joins => "INNER JOIN users cond_users ON cond_users.id = orders.user_id"
    }
    @form.to_paginate_options(:page => '2').should == 
      {:per_page => 50, :page => '2'}.update(@form.to_find_options)
  end

  it "user_name2" do
    @form = OrderFinderForm2.new(:user_name2 => 'ABC')
    @form.to_find_options.should == {
      :conditions => ["cond_users.name LIKE ?", 'ABC%'],
      :joins => "INNER JOIN users cond_users ON cond_users.id = orders.user_id"
    }
    @form.to_paginate_options(:page => nil).should == 
      {:per_page => 50}.update(@form.to_find_options)
  end

  it "user_name3" do
    @form = OrderFinderForm2.new(:user_name3 => 'ABC')
    @form.to_find_options.should == {
      :conditions => ["cond_users.name LIKE ?", '%ABC'],
      :joins => "INNER JOIN users cond_users ON cond_users.id = orders.user_id"
    }
    @form.to_paginate_options(:page => 3).should == 
      {:per_page => 50, :page => 3}.update(@form.to_find_options)
  end

end
