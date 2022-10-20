# frozen_string_literal: true

# In this data migration, we copy the values from deprecated Pacbio columns to
# the smrt_link_options column (store) of Pacbio Wells. The options are
# accessible just like any attribute of the model. If there is a deprecated
# column for an option key and the option is not in the store yet, we copy the
# value.

namespace :pacbio_wells do
  task migrate_smrt_link_options: :environment do
    hifi_options = { 0 => 'In SMRT Link', 1 => 'On Instrument', 2 => 'Do Not Generate' }
    # We have to assume it is v10
    wells = Pacbio::Well.all
    wells.each do |well|
      if well.generate_hifi_deprecated.present? && well.generate_hifi.nil?
        well.generate_hifi = hifi_options[well.generate_hifi_deprecated]
      end

      if well.ccs_analysis_output_deprecated.present? && well.ccs_analysis_output.nil?
        well.ccs_analysis_output = well.ccs_analysis_output_deprecated
      end

      if well.on_plate_loading_concentration_deprecated.present? && well.on_plate_loading_concentration.nil?
        well.on_plate_loading_concentration = well.on_plate_loading_concentration_deprecated
      end

      if well.binding_kit_box_barcode_deprecated.present? && well.binding_kit_box_barcode.nil?
        well.binding_kit_box_barcode = well.binding_kit_box_barcode_deprecated
      end

      if well.pre_extension_time_deprecated.present? && well.pre_extension_time.nil?
        well.pre_extension_time = well.pre_extension_time_deprecated
      end

      if well.loading_target_p1_plus_p2_deprecated.present? && well.loading_target_p1_plus_p2.nil?
        well.loading_target_p1_plus_p2 = well.loading_target_p1_plus_p2_deprecated
      end

      if well.movie_time_deprecated.present? && well.movie_time.nil?
        well.movie_time = well.movie_time_deprecated
      end

      well.save!
    end

    puts "-> #{wells.length} instances of pacbio well updated."
  end
end
