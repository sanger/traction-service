class Sample < ApplicationRecord
  attr_readonly :name
  validates_presence_of :name
  validates_uniqueness_of :name

  def save
    Sample.create!(name: self.name)
  end

  def active?
    deactivated_at.nil?
  end
end
