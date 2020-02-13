# frozen_string_literal: true

# Pacbio
module Pacbio
  def self.table_name_prefix
    'pacbio_'
  end

  def self.request_attributes
    %i[
      library_type estimate_of_gb_required number_of_smrt_cells cost_code
      external_study_id source_barcode
    ]
  end

  def self.required_request_attributes
    [
      :external_study_id
    ]
  end
end
