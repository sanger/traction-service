# frozen_string_literal: true

# QcResultsUpload
class QcResultsUpload < ApplicationRecord
  extend NestedValidation

  validates :csv_data, :used_by, presence: true

  delegate :create_entities!, to: :qc_results_upload_factory

  validates_nested :qc_results_upload_factory, flatten_keys: true

  private

  def qc_results_upload_factory
    @qc_results_upload_factory ||= QcResultsUploadFactory.new(qc_results_upload: self)
  end
end
