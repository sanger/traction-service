# frozen_string_literal: true

# SmrtLinkVersionType
class SmrtLinkVersionType < ActiveRecord::Type::String
  # if the smrt link version is nil then we need to set it
  # to the default
  def cast(value)
    if value.present?
      super
    else
      super(Version::SmrtLink::DEFAULT)
    end
  end
end
