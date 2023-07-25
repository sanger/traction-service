# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

RSpec.describe 'RakeTasks' do
  before do
    Pacbio::SmrtLinkVersion.find_by(name: 'v10') || create(:pacbio_smrt_link_version, name: 'v10', default: true)
    Pacbio::SmrtLinkVersion.find_by(name: 'v11') || create(:pacbio_smrt_link_version, name: 'v11')
    Pacbio::SmrtLinkVersion.find_by(name: 'v12_revio') || create(:pacbio_smrt_link_version, name: 'v12_revio')
  end

  describe 'pacbio_wells:migrate_smrt_link_options' do
    # We need to set the smrt link version to v12 so it is not validated
    # generate_hifi - 'In SMRT Link' => 0, 'On Instrument' => 1, 'Do Not Generate' => 2
    let!(:version12) { create(:pacbio_smrt_link_version, name: 'v12') }
    let!(:run) { create(:pacbio_run, system_name: 0, smrt_link_version: version12) }
    let!(:plate) { create(:pacbio_plate, run:) }
    let!(:well1) { create(:pacbio_well, generate_hifi_deprecated: 0, generate_hifi: nil, plate:) }
    let!(:well2) { create(:pacbio_well, generate_hifi_deprecated: 1,  generate_hifi: nil, plate:) }
    let!(:well3) { create(:pacbio_well, generate_hifi_deprecated: 2,  generate_hifi: nil, plate:) }
    let!(:well4) { create(:pacbio_well, ccs_analysis_output_deprecated: 'Yes', ccs_analysis_output: nil, plate:) }
    let!(:well5) { create(:pacbio_well, ccs_analysis_output_deprecated: 'No',  ccs_analysis_output: nil, plate:) }

    it 'modifies the data correctly' do
      expect(Pacbio::Well.count).to eq(6) # create(:pacbio_plate) also creates a well
      Rake::Task['pacbio_wells:migrate_smrt_link_options'].invoke
      [well1, well2, well3, well4, well5].collect(&:reload)
      expect(well1.generate_hifi).to eq('In SMRT Link')
      expect(well2.generate_hifi).to eq('On Instrument')
      expect(well3.generate_hifi).to eq('Do Not Generate')
      expect(well4.ccs_analysis_output).to eq('Yes')
      expect(well5.ccs_analysis_output).to eq('No')
    end
  end

  describe 'deprecate_existing_pacbio_smrt_link_columns' do
    let!(:version) { create(:pacbio_smrt_link_version, name: 'v12') }

    it 'migrates data from deprecated columns to store' do
      well = build(
        :pacbio_well,
        on_plate_loading_concentration_deprecated: 1,
        on_plate_loading_concentration: nil,
        binding_kit_box_barcode_deprecated: '2',
        binding_kit_box_barcode: nil,
        pre_extension_time_deprecated: 3,
        pre_extension_time: nil,
        loading_target_p1_plus_p2_deprecated: 0.4,
        loading_target_p1_plus_p2: nil,
        movie_time_deprecated: 5,
        movie_time: nil,
        plate: create(:pacbio_plate, run: create(:pacbio_run, system_name: 0, smrt_link_version: version))
      )
      # Skip validations in the following to be able set nil for options as
      # entry condition.
      well.save!(validate: false)

      # Reenabling the task makes it possible to invoke again.
      # Invoke the data migration task for smrt_link options.
      Rake::Task['pacbio_wells:migrate_smrt_link_options'].reenable
      Rake::Task['pacbio_wells:migrate_smrt_link_options'].invoke

      # Reload the attributes of the record from the database.
      # We want to see what was saved by the task.
      well.reload

      expect(well.on_plate_loading_concentration).to eq(1)
      expect(well.binding_kit_box_barcode).to eq('2')
      expect(well.pre_extension_time).to eq(3)
      expect(well.loading_target_p1_plus_p2).to eq(0.4)
      expect(well.movie_time).to eq(5)
    end
  end
end
