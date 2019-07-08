# frozen_string_literal: true

# Saphyr namespace
module Saphyr
  def self.table_name_prefix
    'saphyr_'
  end

  def self.attributes
    [
      :external_study_id
    ]
  end
end
