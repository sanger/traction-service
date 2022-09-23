# frozen_string_literal: true

# tried to namespace this under module Pacbio
# not playing ball
module SmrtLink
  # This is a set of constants and methods to help identify and
  # validate SMRT Link versioning.
  # This is stage 1 which may be changed and adapted via the
  # next story
  module Versions
    # Default SMRT Link version
    # DEFAULT = 'v10'

    # Currently available SMRT Link Versions
    AVAILABLE = %w[v10 v11].freeze

    # Valid values for SMRT Link options
    YES_NO = %w[Yes No].freeze
    GENERATE = ['In SMRT Link', 'On Instrument', 'Do Not Generate'].freeze

    # For each version there are required fields with a defined set of values to
    # validate against
    def self.required_fields_by_version
      {
        v10: {
          generate_hifi: GENERATE,
          ccs_analysis_output: YES_NO
        },
        v11: {
          ccs_analysis_output_include_kinetics_information: YES_NO,
          ccs_analysis_output_include_low_quality_reads: YES_NO,
          fivemc_calls_in_cpg_motifs: YES_NO,
          demultiplex_barcodes: GENERATE
        }
      }.with_indifferent_access
    end
  end
end
