class Sample < ApplicationRecord
  attr_readonly :name
  validates_uniqueness_of :name
end
