module Utilities::Arrays
  def self.same?(array1, array2)
    ((array1 - array2) + (array2 - array1)).empty?
  end

  # are values from smaller array1 all included in bigger array2 ?
  def self.included_in?(array1, array2)
    (array1 - array2).empty?
  end
end
