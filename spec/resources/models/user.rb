# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  has_many :orders
end
