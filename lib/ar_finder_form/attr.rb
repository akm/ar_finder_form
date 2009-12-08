require 'ar_finder_form'
module ArFinderForm
  module Attr
    autoload :Base, 'ar_finder_form/attr/base'
    autoload :Static, 'ar_finder_form/attr/static'
    autoload :Simple, 'ar_finder_form/attr/simple'
    autoload :Like, 'ar_finder_form/attr/like'
    autoload :RangeAttrs, 'ar_finder_form/attr/range_attrs'

  end
end
