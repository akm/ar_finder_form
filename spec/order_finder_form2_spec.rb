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
      column(:name, :attr => :user_name)
    end
    
  end
end


describe OrderFinderForm2 do
  
  it "no attribute" do
    form2 = OrderFinderForm2.new
    form2.to_find_options.should == {}
  end
  
  it "user_name" do
    form2 = OrderFinderForm2.new(:user_name => 'ABC')
    form2.to_find_options.should == {
      :conditions => ["cond_users.name LIKE ?", '%ABC%'],
      :joins => "INNER JOIN users cond_users ON cond_users.id = orders.user_id"
    }
  end

end
