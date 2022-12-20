# frozen_string_literal: true

module V1
  # QcResultsUploadsController
  class QcResultsUploadsController < ApplicationController
    before_action { not_found unless Flipper.enabled?(:dpl_478_enable_qc_results_upload) }
  end
end
