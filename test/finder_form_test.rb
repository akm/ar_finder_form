# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'test_helper')

class FinderFormTest < Test::Unit::TestCase


  class BookFinder < ::FinderForm::Base
    table "books" do 
      parameter 'title'
      parameter 'author'
      parameter 'isbn', :match => :forward
      parameter 'published_date', :type => :date, :range_with => true
    end
    
    order :default => "1" do
      enum do
        entry '1', 'title', "タイトル順", :order => "title asc, id asc"
        entry '2', 'author', "著者名順", :order => "author asc, id asc"
        entry '3', 'published_date', "出版日が新しい順", :order => "published_date desc, id desc"
        entry '4', 'published_date', "出版日が古い順", :order => "published_date asc, id asc"
      end
    end
    
    per_page :default => 10 do
      enum do 
        entry 10, :record_10, "10件"
        entry 20, :record_20, "20件"
        entry 50, :record_50, "50件"
      end
    end
  end
  
  def test_book_finder
    f = BookFinder.new(:order_cd => '', :title => '', :author => '', :isbn => '', :published_date_min => '')
    assert_hash({:per_page => 10}, f.to_paginate_options)
    assert_hash({}, f.to_find_options)

    f = BookFinder.new(:order_cd => '2', :title => '', :author => '', :isbn => '1234567', :published_date_min => '', :per_page => '20')
    f.build
    assert_equal('2', f.order_cd)
    assert_equal(20, f.per_page)
    assert Integer === f.per_page
    assert_hash({:order_cd => '2', :isbn => '1234567', :per_page => 20}, f.attributes)
    assert_hash({'finder[order_cd]' => '2', 'finder[isbn]' => '1234567', 'finder[per_page]' => 20}, 
      f.attributes_for(:object_name => 'finder'))
    assert_hash({
        :per_page => 20,
        :order => 'author asc, id asc',
        :conditions => ["books.isbn like :isbn", {:isbn => "1234567%"}]
      }, f.to_paginate_options)
    assert_hash({
        :order => 'author asc, id asc',
        :conditions => ["books.isbn like :isbn", {:isbn => "1234567%"}]
      }, f.to_find_options)

    f = BookFinder.new(:order_cd => '3', :title => '', :author => '', :isbn => '', 
      :published_date_min => '2008/02/24', :per_page => '50')
    assert_hash({
        :per_page => 50,
        :order => 'published_date desc, id desc',
        :conditions => ["books.published_date >= :published_date_min", 
          {:published_date_min => Date.parse('2008/02/24')}]
      }, f.to_paginate_options)
  end

  class PersonFinder < ::FinderForm::Base
    table 'people' do
      parameter 'name', :type => :string
      parameter 'person_code', :type => :string, :match => :exact
      parameter 'occupation', :type => :string, :match => :forward
      parameter 'age', :type => :integer, :range_with => true, :exclude_max => true
      parameter 'created_at', :type => :time, :range_with => true
      parameter 'updated_on', :type => :date, :range_with => [:start, :end],
        :exclude_begin => true, :exclude_end => true
      parameter 'deleted_cd', :type => :integer, :param_value => nil, :default => 1 do
        enum do
          entry 1, :exclude_deleted, '削除されたものを含まない', :conditions => "deleted_cd <> 1"
          entry 2, :include_deleted, '削除されたものを含める', :conditions => nil
          entry 3, :deleted_only, '削除されたもののみを含める', :conditions => "deleted_cd = 1"
        end
      end
      parameter 'category_cds', :type => :string_array, :column => 'category_cd', :default => '' do
        enum_array do
          entry 'M1', :m1, '男性20～34歳'
          entry 'M2', :m2, '男性35～49歳'
          entry 'M3', :m3, '男性50歳～'
          entry 'F1', :f1, '女性20～34歳'
          entry 'F2', :f2, '女性35～49歳'
          entry 'F3', :f3, '女性50歳～'
        end
      end
    end
    
    inner_join 'telephones', :on => 'telephones.person_id = people.id' do
      parameter 'telephone_no', :type => :string
      parameter 'telephone_type_cds', :type => :integer_array, :column => 'telephone_type_cd', :default => '' do
        enum_array do
          entry 1, :home_phone, '家電'
          entry 2, :mobile, '携帯'
          entry 3, :fax, 'FAX'
          entry 4, :other, 'その他'
        end
      end
    end
    
    order :default => 1 do
      enum do
        entry 1, :name_asc, '名前 昇順', :order => 'people.name asc'
        entry 2, :telephone_no_asc, '電話番号 昇順', :order => 'telephones.telephone_no asc', :joins => 'inner join telephones on telephones.person_id = people.id'
        entry 3, :telephone_no_desc, '電話番号 降順', :order => 'telephones.telephone_no desc', :tables => 'telephones'
      end
    end
  end
  
  def test_person_finder
    f = PersonFinder.new
    f.build
    assert_equal({:order_cd => 1, :deleted_cd => 1}, f.attributes)
    assert_hash({
        :conditions => ["deleted_cd <> 1", {}],
        :order => 'people.name asc'
      }, f.to_paginate_options)
    
    f = PersonFinder.new(:age_min => '20', :age_max => '30')
    assert_hash({
        :conditions => ["people.age >= :age_min AND people.age < :age_max AND deleted_cd <> 1", 
          {:age_min => 20, :age_max => 30}],
        :order => 'people.name asc'
      }, f.to_paginate_options)
    
    f = PersonFinder.new(:age_min => '20')
    assert_hash({
        :conditions => ["people.age >= :age_min AND deleted_cd <> 1", 
          {:age_min => 20}],
        :order => 'people.name asc'
      }, f.to_paginate_options)
    
    f = PersonFinder.new(:order_cd => '2', :deleted_cd => 1, :name => '坂本', :telephone_no => '03-')
    assert_hash({
        :order => 'telephones.telephone_no asc',
        :joins => 'inner join telephones on telephones.person_id = people.id',
        :conditions => [
            "people.name like :name AND deleted_cd <> 1 AND telephones.telephone_no like :telephone_no", 
            {:name => "%坂本%", :telephone_no => "%03-%"}
          ]
      }, f.to_paginate_options)
    
    f = PersonFinder.new(:order_cd => '2', :deleted_cd => 1, :name => '坂本', :telephone_no => '')
    assert_hash({
        :order => 'telephones.telephone_no asc',
        :joins => 'inner join telephones on telephones.person_id = people.id',
        :conditions => [
            "people.name like :name AND deleted_cd <> 1", 
            {:name => "%坂本%"}
          ]
      }, f.to_paginate_options)
    
    f = PersonFinder.new(:order_cd => '3', :deleted_cd => '1', :name => '坂本', :telephone_no => '')
    assert_hash({
        :order => 'telephones.telephone_no desc',
        :joins => 'inner join telephones on telephones.person_id = people.id',
        :conditions => [
            "people.name like :name AND deleted_cd <> 1", 
            {:name => "%坂本%"}
          ]
      }, f.to_paginate_options)
    
    f = PersonFinder.new(:order_cd => '3', :deleted_cd => '3', :name => '坂本', :telephone_no => '', :occupation => 'プログラマ')
    assert_hash({
        :order => 'telephones.telephone_no desc',
        :joins => 'inner join telephones on telephones.person_id = people.id',
        :conditions => [
            "people.name like :name AND people.occupation like :occupation AND deleted_cd = 1",
            {:name => "%坂本%", :occupation => 'プログラマ%'}
          ]
      }, f.to_paginate_options)
    
    f = PersonFinder.new(:order_cd => '3', :deleted_cd => '2', :name => '坂本', :telephone_no => '', :person_code => '12345', :occupation => 'プログラマ')
    assert_hash({
        :order => 'telephones.telephone_no desc',
        :joins => 'inner join telephones on telephones.person_id = people.id',
        :conditions => [
            "people.name like :name AND people.person_code = :person_code AND people.occupation like :occupation", 
            {:name => "%坂本%", :person_code => '12345', :occupation => 'プログラマ%'}
          ]
      }, f.to_paginate_options)
    
    f = PersonFinder.new(:order_cd => '1', :deleted_cd => '2', :telephone_no => '', :created_at_min => '2008/02/24')
    assert_hash({
        :order => 'people.name asc',
        :conditions => ["people.created_at >= :created_at_min", {:created_at_min => Time.parse('2008/02/24')}]
      }, f.to_paginate_options)
    
    f = PersonFinder.new(:order_cd => '1', :deleted_cd => '2', :telephone_no => '', :created_at_max => '2008/04/06')
    assert_hash({
        :order => 'people.name asc',
        :conditions => ["people.created_at <= :created_at_max", {:created_at_max => Time.parse('2008/04/06')}]
      }, f.to_paginate_options)
    
    f = PersonFinder.new(:order_cd => '1', :deleted_cd => '2', :telephone_no => '', 
      :created_at_min => '2008/02/24', :created_at_max => '2008/04/06')
    assert_hash({
        :order => 'people.name asc',
        :conditions => ["people.created_at >= :created_at_min AND people.created_at <= :created_at_max", 
          {:created_at_min => Time.parse('2008/02/24'), :created_at_max => Time.parse('2008/04/06')}]
      }, f.to_paginate_options)

    f = PersonFinder.new(:order_cd => '1', :deleted_cd => '2', :category_ids => ["M2","M3","F1","F2"])
    assert_equal ["M2","M3","F1","F2"], f.category_cds
    assert_hash({
        :order => 'people.name asc',
        :conditions => ["people.category_cd in (:category_cds)", 
          {:category_cds => ['M2','M3','F1','F2']}]
      }, f.to_paginate_options)

    f = PersonFinder.new(:order_cd => '1', :deleted_cd => '2', :telephone_type_cds => '2,3,4')
    assert_hash({
        :order => 'people.name asc',
        :joins => 'inner join telephones on telephones.person_id = people.id',
        :conditions => ["telephones.telephone_type_cd in (:telephone_type_cds)", 
          {:telephone_type_cds => [2,3,4]}]
      }, f.to_paginate_options)
    assert_equal([2,3,4], f.telephone_type_cds)
  end
end
