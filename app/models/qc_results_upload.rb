# frozen_string_literal: true

# QcResultsUpload
class QcResultsUpload < ApplicationRecord
  extend NestedValidation

  # Before QcResultsUpload creation, run qc_results_upload_factory validation
  validates_nested :qc_results_upload_factory, flatten_keys: true

  delegate :create_entities!, :messages, to: :qc_results_upload_factory

  private

  def qc_results_upload_factory
    @qc_results_upload_factory ||= QcResultsUploadFactory.new(qc_results_upload: self)
  end
end
