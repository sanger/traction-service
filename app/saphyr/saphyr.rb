# frozen_string_literal: true

# Saphyr namespace
module Saphyr
  def self.table_name_prefix
    'saphyr_'
  end

  def self.request_attributes
    [
      :external_study_id
    ]
  end
end
