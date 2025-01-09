# frozen_string_literal: true

# A class spefically for SMRT-Link v25 Sample Sheets, based on the PacbioSampleSheet class
# See https://www.pacb.com/wp-content/uploads/SMRT-Link-User-Guide-v25.1.pdf (page 28) for details.

module RunCsv
  # RunCsv::PacbioSampleSheet
  class PacbioSampleSheetV25 < PacbioSampleSheet
    # Generate a hash of settings for a single cell
    # Overrides the method in the parent class
    # Only difference is removal of 'Polymerase Kit' key
    def generate_smrt_cell_settings(well) # rubocop:disable Metrics/MethodLength
      {
        'Well Name'	=> well.used_aliquots.first.source.tube.barcode, # TRAC-2-7242
        'Library Type'	=> well.library_type, # Standard
        'Movie Acquisition Time (hours)'	=> well.movie_acquisition_time, # 24
        'Insert Size (bp)'	=> well.insert_size, # 500
        'Assign Data To Project'	=> 1, # (maybe we need to assign a run a project in traction)?
        'Library Concentration (pM)'	=> well.library_concentration, # 250
        'Include Base Kinetics'	=> well.include_base_kinetics,
        'Indexes'	=> well.barcode_set, # 244d96c6-f3b2-4997-5ae3-23ed33ab925f
        'Sample is indexed'	=> well.tagged?, # Set to True to Multiplex
        'Bio Sample Name' => well.tagged? ? nil : well.bio_sample_name,
        'Use Adaptive Loading'	=> well.use_adaptive_loading,
        'Consensus Mode'	=> 'molecule', # (default to molecule do we need a custom field)
        'Same Barcodes on Both Ends of Sequence'	=> well.same_barcodes_on_both_ends_of_sequence,
        'Full Resolution Base Qual' => well.full_resolution_base_qual
      }
    end
  end
end
