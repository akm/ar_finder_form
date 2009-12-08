# -*- coding: utf-8 -*-
module ArFinderForm

  autoload :Config, 'ar_finder_form/config'
  autoload :ClientClassMethods, 'ar_finder_form/client_class_methods'
  autoload :ClientInstanceMethods, 'ar_finder_form/client_instance_methods'
  autoload :Table, 'ar_finder_form/table'
  autoload :JoinedTable, 'ar_finder_form/joined_table'
  autoload :Column, 'ar_finder_form/column'
  autoload :Attr, 'ar_finder_form/attr'
  autoload :Builder, 'ar_finder_form/builder'
  autoload :Context, 'ar_finder_form/context'

  def self.included(mod)
    mod.extend(ClientClassMethods)
    mod.module_eval do
      include ClientInstanceMethods
    end
  end

  def self.config
    @config ||= Config.new
  end

end
