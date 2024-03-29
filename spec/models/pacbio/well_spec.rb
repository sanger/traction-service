# frozen_string_literal: true

require 'rails_helper'

# These tests may end up being redundant but we need to make sure existing validations still work
# when this work is merged with yaml file for validations it would be better to load those
# validations rather than setting them here
# Make sure there is a default version to be able to create a run
RSpec.describe Pacbio::Well, :pacbio do
  let!(:version10) { create(:pacbio_smrt_link_version, name: 'v10') }
  let!(:version11) { create(:pacbio_smrt_link_version, name: 'v11', default: true) }
  let!(:version12_revio) { create(:pacbio_smrt_link_version, name: 'v12_revio') }

  before do
    Flipper.enable(:dpl_1112)
  end

  context 'uuidable' do
    let(:uuidable_model) { :pacbio_well }

    it_behaves_like 'uuidable'
  end

  context 'row' do
    it 'must have a row' do
      expect(build(:pacbio_well, row: nil)).not_to be_valid
    end
  end

  context 'column' do
    it 'must have a column' do
      expect(build(:pacbio_well, column: nil)).not_to be_valid
    end
  end

  context 'insert size' do
    it 'gets the insert size of the first pool in the well' do
      pools = create_list(:pacbio_pool, 2)
      well = create(:pacbio_well, pools:)
      expect(pools[0].insert_size).to eq(well.insert_size)
    end

    it 'gets the insert size of the first library in the well' do
      libraries = create_list(:pacbio_library, 2)
      well = create(:pacbio_well, libraries:, pools: [])
      expect(libraries[0].insert_size).to eq(well.insert_size)
    end
  end

  context 'position' do
    it 'can have a position' do
      expect(build(:pacbio_well, row: 'B', column: '1').position).to eq('B1')
    end
  end

  it 'must have to a plate' do
    expect(build(:pacbio_well, plate: nil)).not_to be_valid
  end

  it 'can have a comment' do
    expect(build(:pacbio_well).comment).to be_present
  end

  it 'can have a summary' do
    well = create(:pacbio_well_with_pools)
    expect(well.summary).to eq("#{well.sample_names} #{well.comment}")
  end

  describe '#pools?' do
    let(:pools) { create_list(:pacbio_pool, 2) }

    it 'with pools' do
      well = create(:pacbio_well, pools:)
      expect(well.pools?).to be true
    end

    it 'no pools' do
      well = build(:pacbio_well, pool_count: 0)
      expect(well.pools?).to be false
    end
  end

  describe '#libraries?' do
    let(:libraries) { create_list(:pacbio_library, 2) }

    it 'with libraries' do
      well = create(:pacbio_well, libraries:)
      expect(well.libraries?).to be true
    end

    it 'no libraries' do
      well = build(:pacbio_well, libraries: [])
      expect(well.libraries?).to be false
    end
  end

  describe 'used_aliquots' do
    it 'is invalid without used_aliquots when feature flag is on' do
      Flipper.enable(:dpl_1112)
      # A pool will create a used_aliquot
      well = create(:pacbio_well, pool_count: 1)
      well.used_aliquots.destroy_all

      expect(well).not_to be_valid
    end

    it 'is valid without used_aliquots when feature flag is off' do
      Flipper.disable(:dpl_1112)
      # A pool will create a used_aliquot
      well = create(:pacbio_well, pool_count: 1)
      well.used_aliquots.destroy_all

      expect(well).to be_valid
    end
  end

  context 'libraries' do
    let(:lib1)      { create(:pacbio_library, :tagged) }
    let(:lib2)      { create(:pacbio_library, :tagged) }
    let(:libraries) { [lib1, lib2] }
    let(:well)      { create(:pacbio_well, libraries:) }

    it 'can have one or more' do
      expect(well.libraries).to eq(libraries)
    end
  end

  context 'pools' do
    let(:pools) { create_list(:pacbio_pool, 2) }
    let(:well)  { create(:pacbio_well, pools:) }

    it 'can have one or more' do
      expect(well.pools.length).to eq(2)
    end

    it 'can return a list of sample names' do
      sample_names = well.sample_names.split(':')
      expect(sample_names.length).to eq(2)
      expect(sample_names.first).to eq(well.pools.first.libraries.first.request.sample_name)

      sample_names = well.sample_names(',').split(',')
      expect(sample_names.length).to eq(2)
      expect(sample_names.first).to eq(well.pools.first.libraries.first.request.sample_name)
    end

    it 'can return a list of tags' do
      tag_ids = well.all_libraries.collect(&:tag_id)
      expect(well.tags).to eq(tag_ids)
    end
  end

  context 'pool_ids=' do
    it 'creates well_pools and used_aliquots from pool_ids' do
      pools_ids = create_list(:pacbio_pool, 2).collect(&:id)
      well = build(:pacbio_well, pool_count: 0)

      expect(well.pools.length).to eq(0)
      expect(well.used_aliquots.length).to eq(0)
      well.pool_ids = pools_ids
      well.save

      expect(well.pools.length).to eq(2)
      expect(well.used_aliquots.length).to eq(2)
    end

    it 'destroys well_pools and used_aliquots from pool_ids' do
      well = create(:pacbio_well, pool_count: 2)

      expect(well.pools.length).to eq(2)
      expect(well.used_aliquots.length).to eq(2)

      well.pool_ids = [well.pools.first.id]
      well.reload

      expect(well.pools.length).to eq(1)
      expect(well.used_aliquots.length).to eq(1)
    end
  end

  context 'library_ids=' do
    it 'creates well_libraries and used_aliquots from library_ids' do
      library_ids = create_list(:pacbio_library, 2).collect(&:id)
      well = build(:pacbio_well, pool_count: 0, library_count: 0)

      expect(well.libraries.length).to eq(0)
      expect(well.used_aliquots.length).to eq(0)
      well.library_ids = library_ids
      well.save

      expect(well.libraries.length).to eq(2)
      expect(well.used_aliquots.length).to eq(2)
    end

    it 'destroys well_pools and used_aliquots from pool_ids' do
      well = create(:pacbio_well, pool_count: 0, library_count: 2)

      expect(well.libraries.length).to eq(2)
      expect(well.used_aliquots.length).to eq(2)

      well.library_ids = [well.libraries.first.id]
      well.reload

      expect(well.libraries.length).to eq(1)
      expect(well.used_aliquots.length).to eq(1)
    end
  end

  context 'all_libraries' do
    let(:pools) { create_list(:pacbio_pool, 2, library_count: 1) }
    let(:libraries) { create_list(:pacbio_library, 2) }

    it 'returns a combined list of libraries from pools and libraries' do
      well = create(:pacbio_well, pools:, libraries:)

      all_libraries = well.pools.collect(&:libraries).flatten + well.libraries
      expect(well.all_libraries.length).to eq(4)
      expect(well.all_libraries).to eq(all_libraries)
    end
  end

  context 'sample sheet mixin' do
    let(:well) { create(:pacbio_well) }

    it 'includes the Sample Sheet mixin' do
      expect(well.same_barcodes_on_both_ends_of_sequence).to be true
    end
  end

  context 'template prep kit box barcode' do
    it 'gets the template prep kit box barcode of the first pool in the well' do
      pools = create_list(:pacbio_pool, 2)
      well = create(:pacbio_well, pools:)
      expect(pools[0].template_prep_kit_box_barcode).to eq(well.template_prep_kit_box_barcode)
    end

    it 'gets the template prep kit box barcode of the first library in the well' do
      libraries = create_list(:pacbio_library, 2)
      well = create(:pacbio_well, libraries:, pools: [])
      expect(libraries[0].template_prep_kit_box_barcode).to eq(well.template_prep_kit_box_barcode)
    end
  end

  context 'collection?' do
    let(:well) { create(:pacbio_well) }

    it 'alwayses be true' do
      expect(well).to be_collection
    end
  end

  context 'Smrt Link Options' do
    let(:well)  { create(:pacbio_well) }
    let(:generate_in) { Pacbio::GENERATE }
    let(:yes_no) { Pacbio::YES_NO }
    let(:true_false) { Pacbio::TRUE_FALSE }

    it 'includes the relevant options' do
      expect(described_class.stored_attributes[:smrt_link_options]).to eq(%i[
        ccs_analysis_output
        generate_hifi
        ccs_analysis_output_include_low_quality_reads
        include_fivemc_calls_in_cpg_motifs
        ccs_analysis_output_include_kinetics_information
        demultiplex_barcodes
        on_plate_loading_concentration
        binding_kit_box_barcode
        pre_extension_time
        loading_target_p1_plus_p2 movie_time
        movie_acquisition_time
        include_base_kinetics
        library_concentration
        polymerase_kit
      ])
    end

    context 'v10 or v11' do
      before do
        # v10 and v11 validations
        create(:pacbio_smrt_link_option, key: :movie_time, validations: { presence: {}, numericality: { greater_than_or_equal_to: 0.1, less_than_or_equal_to: 30 } }, smrt_link_versions: [version10, version11])
        create(:pacbio_smrt_link_option, key: :binding_kit_box_barcode, validations: { presence: {} }, smrt_link_versions: [version10, version11])
        create(:pacbio_smrt_link_option, key: :on_plate_loading_concentration, validations: { presence: {} }, smrt_link_versions: [version10, version11])
        create(:pacbio_smrt_link_option, key: :pre_extension_time, validations: { numericality: { allow_blank: true } }, smrt_link_versions: [version10, version11])
        create(:pacbio_smrt_link_option, key: :loading_target_p1_plus_p2, validations: { numericality: { allow_blank: true, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0 } }, smrt_link_versions: [version10, version11])
      end

      # we need to create this after creating smrt link options otherwise they will not be added
      let!(:run) { create(:pacbio_sequel_run, smrt_link_version: version11) }
      let(:plate) { run.plates.first }

      context 'movie time' do
        it 'must be present' do
          expect(build(:pacbio_well, movie_time: nil, plate:)).not_to be_valid
        end

        it 'can be a decimal' do
          expect(build(:pacbio_well, movie_time: 0.2, plate:).movie_time).to eq(0.2)
        end

        it 'must be within range' do
          expect(build(:pacbio_well, movie_time: 15, plate:)).to be_valid
          expect(build(:pacbio_well, movie_time: 31, plate:)).not_to be_valid
          expect(build(:pacbio_well, movie_time: 0, plate:)).not_to be_valid
        end
      end

      it 'must have a sequencing kit box barcode for plate 1 only' do
        well = build(:pacbio_well, plate:)

        expect(well.sequencing_kit_box_barcode_plate_1).to be(well.plate.sequencing_kit_box_barcode)
        expect(well.sequencing_kit_box_barcode_plate_2).to be_nil
      end

      it 'must have an on plate loading concentration' do
        expect(build(:pacbio_well, on_plate_loading_concentration: nil, plate:)).not_to be_valid
      end

      it 'must have a binding kit box barcode' do
        expect(build(:pacbio_well, binding_kit_box_barcode: nil, plate:)).not_to be_valid
      end

      context 'pre-extension time' do
        it 'is not required' do
          expect(create(:pacbio_well, pre_extension_time: nil, plate:)).to be_valid
        end

        it 'can be set' do
          expect(build(:pacbio_well, pre_extension_time: 2, plate:).pre_extension_time).to eq(2)
        end

        it 'can be a decimal' do
          expect(build(:pacbio_well, pre_extension_time: 2.5, plate:)).to be_valid
        end

        it 'must be a number' do
          expect(build(:pacbio_well, pre_extension_time: 'NaN', plate:)).not_to be_valid
        end
      end

      context 'loading target p1 plus p2' do
        it 'is not required' do
          expect(build(:pacbio_well, loading_target_p1_plus_p2: nil, plate:)).to be_valid
        end

        it 'can be a decimal' do
          expect(build(:pacbio_well,
                       loading_target_p1_plus_p2: 0.5, plate:).loading_target_p1_plus_p2).to eq(0.5)
        end

        it 'must be within range' do
          expect(build(:pacbio_well, loading_target_p1_plus_p2: 0.45, plate:)).to be_valid
          expect(build(:pacbio_well, loading_target_p1_plus_p2: 0, plate:)).to be_valid
          expect(build(:pacbio_well, loading_target_p1_plus_p2: 72, plate:)).not_to be_valid
        end
      end
    end

    context 'v10' do
      before do
        create(:pacbio_smrt_link_option, key: 'generate_hifi', validations: { presence: {}, inclusion: { in: generate_in } }, smrt_link_versions: [version10])
        create(:pacbio_smrt_link_option, key: 'ccs_analysis_output', validations: { presence: {}, inclusion: { in: yes_no } }, smrt_link_versions: [version10])
      end

      let!(:run) { create(:pacbio_sequel_run, smrt_link_version: version10) }
      let!(:well) { build(:pacbio_well, plate: run.plates.first) }

      context 'generate hifi' do
        it 'must be present' do
          well.generate_hifi = nil
          expect(well).not_to be_valid
        end

        it 'must be a valid value' do
          generate_in.each do |option|
            well.generate_hifi = option
            expect(well).to be_valid
          end

          well.generate_hifi = 'junk'
          expect(well).not_to be_valid
        end
      end

      context 'ccs analysis output' do
        it 'must be present' do
          well.ccs_analysis_output = nil
          expect(well).not_to be_valid
        end

        it 'must be a valid value' do
          yes_no.each do |option|
            well.ccs_analysis_output = option
            expect(well).to be_valid
          end

          well.ccs_analysis_output = 'junk'
          expect(well).not_to be_valid
        end
      end
    end

    context 'v11' do
      before do
        create(:pacbio_smrt_link_option, key: 'demultiplex_barcodes', validations: { presence: {}, inclusion: { in: generate_in } }, smrt_link_versions: [version11])
        create(:pacbio_smrt_link_option, key: 'ccs_analysis_output_include_low_quality_reads', validations: { presence: {}, inclusion: { in: yes_no } }, smrt_link_versions: [version11])
        create(:pacbio_smrt_link_option, key: 'ccs_analysis_output_include_kinetics_information', validations: { presence: {}, inclusion: { in: yes_no } }, smrt_link_versions: [version11])
      end

      let!(:run) { create(:pacbio_sequel_run, smrt_link_version: version11) }
      let(:well) { build(:pacbio_well, plate: run.plates.first) }

      context 'CCS Analysis Output - Include Low Quality Reads' do
        it 'must be present' do
          well.ccs_analysis_output_include_low_quality_reads = nil
          expect(well).not_to be_valid
        end

        it 'must be a valid value' do
          yes_no.each do |option|
            well.ccs_analysis_output_include_low_quality_reads = option
            expect(well).to be_valid
          end

          well.ccs_analysis_output_include_low_quality_reads = 'junk'
          expect(well).not_to be_valid
        end
      end

      context 'CCS Analysis Output - Include Kinetics Information' do
        it 'must be present' do
          well.ccs_analysis_output_include_kinetics_information = nil
          expect(well).not_to be_valid
        end

        it 'must be a valid value' do
          yes_no.each do |option|
            well.ccs_analysis_output_include_kinetics_information = option
            expect(well).to be_valid
          end

          well.ccs_analysis_output_include_kinetics_information = 'junk'
          expect(well).not_to be_valid
        end
      end

      context 'Demultiplex barcodes' do
        it 'must be present' do
          expect(well.demultiplex_barcodes).to be_present
        end

        it 'must be a valid value' do
          generate_in.each do |option|
            well.demultiplex_barcodes = option
            expect(well).to be_valid
          end

          well.demultiplex_barcodes = 'junk'
          expect(well).not_to be_valid
        end
      end
    end

    context 'v12_revio' do
      # before do - create all the version12_revio specific options in here
      before do
        create(:pacbio_smrt_link_option, key: 'movie_acquisition_time', validations: { presence: {}, numericality: { greater_than_or_equal_to: 0.1, less_than_or_equal_to: 30 } }, smrt_link_versions: [version12_revio])
        create(:pacbio_smrt_link_option, key: 'include_base_kinetics', validations: { presence: {}, inclusion: { in: true_false } }, smrt_link_versions: [version12_revio])
        create(:pacbio_smrt_link_option, key: 'library_concentration', validations: { presence: {} }, smrt_link_versions: [version12_revio])
        create(:pacbio_smrt_link_option, key: 'polymerase_kit', validations: { presence: {} }, smrt_link_versions: [version12_revio])
      end

      # build the well with the smrt_link version 12 revio
      let!(:run) { create(:pacbio_revio_run, smrt_link_version: version12_revio) }
      let(:well_plate1) { build(:pacbio_well, plate: run.plates.first) }
      let(:well_plate2) { build(:pacbio_well, plate: run.plates.last) }

      context 'Movie acquisition time' do
        it 'must be present' do
          well_plate1.movie_acquisition_time = nil
          expect(well_plate1).not_to be_valid
        end

        it 'can be a decimal' do
          well_plate1.movie_acquisition_time = 0.2
          expect(well_plate1.movie_acquisition_time).to eq(0.2)
        end

        it 'must be within range' do
          well_plate1.movie_acquisition_time = 15
          expect(well_plate1).to be_valid
        end

        it 'is not above range' do
          well_plate1.movie_acquisition_time = 31
          expect(well_plate1).not_to be_valid
        end

        it 'is not below range' do
          well_plate1.movie_acquisition_time = 0
          expect(well_plate1).not_to be_valid
        end
      end

      context 'Include base kinetics' do
        it 'must be present' do
          well_plate1.include_base_kinetics = nil
          expect(well_plate1).not_to be_valid
        end

        it 'must be a valid value' do
          true_false.each do |option|
            well_plate1.include_base_kinetics = option
            expect(well_plate1).to be_valid
          end

          well_plate1.include_base_kinetics = 'junk'
          expect(well_plate1).not_to be_valid
        end
      end

      context 'Library concentration' do
        it 'must have a library concentration' do
          well_plate1.library_concentration = nil
          expect(well_plate1).not_to be_valid
        end
      end

      context 'Polymerase kit' do
        it 'must have a polymerase kit' do
          well_plate1.polymerase_kit = nil
          expect(well_plate1).not_to be_valid
        end

        it 'must be a valid value' do
          well_plate1.polymerase_kit = 'Lxxxxx102739100123199'
          expect(well_plate1).to be_valid
        end
      end

      context 'for the sample sheets' do
        it 'a well on plate 1 must have a sequencing kit box barcode for both plates' do
          expect(well_plate1.sequencing_kit_box_barcode_plate_1).to be(well_plate1.plate.sequencing_kit_box_barcode)
          expect(well_plate1.sequencing_kit_box_barcode_plate_2).to be(well_plate2.plate.sequencing_kit_box_barcode)
        end

        it 'a well on plate 2 must have a sequencing kit box barcode for both plates' do
          expect(well_plate2.sequencing_kit_box_barcode_plate_1).to be(well_plate1.plate.sequencing_kit_box_barcode)
          expect(well_plate2.sequencing_kit_box_barcode_plate_2).to be(well_plate2.plate.sequencing_kit_box_barcode)
        end
      end
    end
  end
end
