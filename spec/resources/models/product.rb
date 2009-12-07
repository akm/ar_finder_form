# -*- coding: utf-8 -*-
class Product < ActiveRecord::Base
  has_many :orders

  selectable_attr :category_cd do
    entry '01', :book, '書籍'
    entry '02', :food, '食品'
    entry '03', :toy, 'おもちゃ'
  end
  
end
