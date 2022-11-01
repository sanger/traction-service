# frozen_string_literal: true

# QcResultsUpload
class QcResultsUpload < ApplicationRecord
  validates :csv_data, presence: true
end
