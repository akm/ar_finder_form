# -*- coding: utf-8 -*-
$KCODE='u'
 
ENV['RAILS_ENV'] ||= 'test'
unless defined?(RAILS_ENV)
  RAILS_ENV = 'test' 
  RAILS_ROOT = File.dirname(__FILE__) unless defined?(RAILS_ROOT)

  require 'rubygems'
  require 'spec'
  require 'spec/matchers'
 
  require 'active_support'
  require 'active_record'
  require 'active_record/fixtures'
  # require 'action_mailer'
  # require 'action_controller'
  # require 'action_view'
  require 'initializer'
 
  require 'yaml'
  config = YAML.load(IO.read(File.join(File.dirname(__FILE__), 'database.yml')))

  ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])
  
  load(File.join(File.dirname(__FILE__), 'schema.rb'))
 
  # ActionController::Routing::Routes.draw do |map|
  #   map.connect ':controller/:action/:id.:format'
  #   map.connect ':controller/:action/:id'
  # end

  gem 'selectable_attr'      , ">=0.3.7"
  gem 'selectable_attr_rails', ">=0.3.7"
  require 'selectable_attr'
  require 'selectable_attr_i18n'
  require 'selectable_attr_rails'
  SelectableAttrRails.add_features_to_active_record
  

  # %w(resources/models resources/controllers).each do |path|
  %w(resources/models).each do |path|
    $LOAD_PATH.unshift File.join(File.dirname(__FILE__), path)
    ActiveSupport::Dependencies.load_paths << File.join(File.dirname(__FILE__), path)
  end
 
  require 'spec/autorun'
  # require 'spec/rails'
 
  $LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
  require File.join(File.dirname(__FILE__), '..', 'init')
 
  Dir.glob("resources/**/*.rb") do |filename|
    require filename
  end
 
  class ActiveSupport::TestCase
    include ActiveRecord::TestFixtures
    self.fixture_path = File.join(File.dirname(__FILE__), 'fixtures')
    self.use_transactional_fixtures = false
    self.use_instantiated_fixtures  = false
    self.pre_loaded_fixtures = false
    fixtures :all
 
    def setup_fixtures_with_set_fixture_path
      # ここでなぜか fixture_path の値が変わってしまっています。。。
      self.class.fixture_path = File.join(File.dirname(__FILE__), 'fixtures')
      setup_fixtures_without_set_fixture_path
    end
    alias_method_chain :setup_fixtures, :set_fixture_path
  end
 
  ActiveRecord::Base.configurations = true

  Spec::Matchers.define :be_ar_column do |name|
    match do |obj|
      obj.class.should <= ActiveRecord::ConnectionAdapters::Column
      obj.name.should == name.to_s
    end
  end
end


