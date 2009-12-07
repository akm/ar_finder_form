require 'finder_form'
module FinderForm
  module Attr
    autoload :Base, 'finder_form/attr/base'
    autoload :Static, 'finder_form/attr/static'
    autoload :Simple, 'finder_form/attr/simple'
    autoload :Like, 'finder_form/attr/like'
    autoload :RangeAttrs, 'finder_form/attr/range_attrs'
    
  end
end
