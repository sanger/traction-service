# frozen_string_literal: true

# QcResultsUpload
class QcResultsUpload < ApplicationRecord
  validates :csv_data, :used_by, presence: true

  delegate :create_entities!, to: :qc_results_upload_factory

  private

  def qc_results_upload_factory
    @qc_results_upload_factory ||= QcResultsUploadFactory.new(qc_results_upload: self)
  end
end
