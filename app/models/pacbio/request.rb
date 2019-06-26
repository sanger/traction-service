# frozen_string_literal: true

module Pacbio
  # Pacbio::Request
  class Request < ApplicationRecord

    validates :library_type, :estimate_of_gb_required, :number_of_smrt_cells, :cost_code, :external_study_id, presence: true
  end
end
