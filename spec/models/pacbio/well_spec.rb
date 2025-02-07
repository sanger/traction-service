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
    well = create(:pacbio_well)
    expect(well.summary).to eq("#{well.sample_names} #{well.comment}")
  end

  describe '#tagged?' do
    let(:well) { create(:pacbio_well, pools:) }

    context 'with tags' do
      let(:pools) { create_list(:pacbio_pool, 1, :tagged) }

      it 'returns true' do
        expect(well.tagged?).to be true
      end
    end

    context 'without tags' do
      let(:pools) { create_list(:pacbio_pool, 1, :untagged) }

      it 'returns false' do
        expect(well.tagged?).to be false
      end
    end
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
    it 'can have one or more' do
      well = create(:pacbio_well, pool_count: 1)

      expect(well.used_aliquots.length).to eq(1)
      expect(well.used_aliquots.first.source).to eq(well.pools.first)
    end

    it 'is not valid unless there is at least one used_aliquot' do
      well = build(:pacbio_well, used_aliquots: [], pool_count: 0)
      expect(well).not_to be_valid
      expect(well.errors.messages[:used_aliquots]).to include("can't be blank")
    end

    it 'accepts nested attributes for used_aliquots' do
      well = described_class.new
      aliquot_attributes = { volume: 10, concentration: 20, aliquot_type: :derived, template_prep_kit_box_barcode: '033000000000000000000' }

      well.used_aliquots_attributes = [aliquot_attributes]

      expect(well.used_aliquots.first.volume).to eq(10)
      expect(well.used_aliquots.first.concentration).to eq(20)
      expect(well.used_aliquots.first.template_prep_kit_box_barcode).to eq('033000000000000000000')
    end

    it 'is not valid when using an invalid amount of volume from a library' do
      libraries = create_list(:pacbio_library, 3, volume: 10)

      # Pool with 3 libraries: 2 invalid ones and one valid
      well = build(:pacbio_well, used_aliquots: [
        create(:aliquot, source: libraries[0], volume: 11, aliquot_type: :derived),
        create(:aliquot, source: libraries[1], volume: 11, aliquot_type: :derived),
        create(:aliquot, source: libraries[2], volume: 9, aliquot_type: :derived)
      ])
      expect(well).not_to be_valid
      expect(well.errors[:base][0]).to eq("Insufficient volume available for #{libraries[0].tube.barcode},#{libraries[1].tube.barcode}")
    end

    it 'is valid when using a valid amount of volume from a library' do
      library = create(:pacbio_library, volume: 100)
      well = build(:pacbio_well, used_aliquots: [build(:aliquot, source: library, volume: 100, aliquot_type: :derived)])
      expect(well).to be_valid
    end

    it 'is not valid when using an invalid amount of volume from a pool' do
      pools = create_list(:pacbio_pool, 3, volume: 10)

      # Pool with 3 pools: 2 invalid ones and one valid
      well = build(:pacbio_well, used_aliquots: [
        create(:aliquot, source: pools[0], volume: 11, aliquot_type: :derived),
        create(:aliquot, source: pools[1], volume: 11, aliquot_type: :derived),
        create(:aliquot, source: pools[2], volume: 9, aliquot_type: :derived)
      ])

      expect(well).not_to be_valid
      expect(well.errors[:base][0]).to eq("Insufficient volume available for #{pools[0].tube.barcode},#{pools[1].tube.barcode}")
    end

    it 'is valid when using a valid amount of volume from a pool' do
      pool = create(:pacbio_pool, volume: 100)
      well = build(:pacbio_well, used_aliquots: [build(:aliquot, source: pool, volume: 100, aliquot_type: :derived)])
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
    let(:well) { create(:pacbio_well, pool_count: 2) }

    it 'can have one or more' do
      expect(well.pools.length).to eq(2)
    end

    it 'can return a list of sample names' do
      sample_names = well.sample_names.split(':')
      expect(sample_names.length).to eq(2)
      expect(sample_names.first).to eq(well.pools.first.used_aliquots.first.source.sample_name)

      sample_names = well.sample_names(',').split(',')
      expect(sample_names.length).to eq(2)
      expect(sample_names.first).to eq(well.pools.first.used_aliquots.first.source.sample_name)
    end

    it 'can return a list of tags' do
      tag_ids = well.base_used_aliquots.collect(&:tag_id)
      expect(well.tags).to eq(tag_ids)
    end
  end

  context 'base_used_aliquots' do
    it 'returns a combined list of used_aliquots from the wells libraries and pools' do
      well = create(:pacbio_well, pool_count: 2, library_count: 2)

      base_used_aliquots = well.used_aliquots.collect(&:source).collect(&:used_aliquots).flatten
      expect(well.base_used_aliquots.length).to eq(4)
      expect(well.base_used_aliquots).to eq(base_used_aliquots)
    end

    it 'removes all used_aliquots marked with _destroy' do
      well = create(:pacbio_well, pool_count: 2, library_count: 2)
      well.used_aliquots.first.mark_for_destruction
      base_used_aliquots = well.used_aliquots.reject(&:marked_for_destruction?).collect(&:source).collect(&:used_aliquots).flatten
      expect(well.base_used_aliquots.length).to eq(3)
      expect(well.base_used_aliquots).to eq(base_used_aliquots)
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

    it 'always be true' do
      expect(well).to be_collection
    end
  end

  context 'Smrt Link Options' do
    let(:well)  { create(:pacbio_well) }
    let(:generate_in) { Pacbio::GENERATE }
    let(:yes_no) { Pacbio::YES_NO }
    let(:true_false) { Pacbio::TRUE_FALSE }

    it 'includes the relevant options' do
      # I have left this as test rather than pulling in the configuration as it is a test of the model
      expect(described_class.stored_attributes[:smrt_link_options]).to eq(%i[
        ccs_analysis_output
        generate_hifi
        ccs_analysis_output_include_kinetics_information
        ccs_analysis_output_include_low_quality_reads
        include_fivemc_calls_in_cpg_motifs
        demultiplex_barcodes
        on_plate_loading_concentration
        binding_kit_box_barcode
        pre_extension_time
        loading_target_p1_plus_p2 movie_time
        movie_acquisition_time
        include_base_kinetics
        library_concentration
        polymerase_kit
        library_type
        use_adaptive_loading
        full_resolution_base_qual
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

  describe 'update smrt_link_options' do
    it 'updates the smrt link option' do
      well = create(:pacbio_well, library_type: nil)
      well.update_smrt_link_options(library_type: 'Standard')
      well.reload
      expect(well.library_type).to eq('Standard')
    end
  end

  context 'sample sheet behaviour' do
    before do
      # Create a default pacbio smrt link version for pacbio runs.
      create(:pacbio_smrt_link_version, name: 'v12_sequel_iie', default: true)
    end

    let(:well) { create(:pacbio_well, pool_count: 5) }

    describe '#barcode_set' do
      it 'returns the tag set uuid' do
        expected_set_name = well.base_used_aliquots.first.tag.tag_set.uuid
        expect(well.barcode_set).to eq expected_set_name
      end

      it 'returns nothing if the aliquots are not tagged' do
        pool = create(:pacbio_pool, :untagged, library_count: 1)
        empty_well = create(:pacbio_well, pools: [pool])
        expect(empty_well.barcode_set).to be_nil
      end

      it 'returns nothing if the aliquots are tagged with a :hidden tag set (egh. IsoSeq)' do
        pool = create(:pacbio_pool, :hidden_tagged, library_count: 1)
        empty_well = create(:pacbio_well, pools: [pool])
        expect(empty_well.barcode_set).to be_nil
      end
    end

    describe '#sample_is_barcoded' do
      it 'returns true if all well aliquots are tagged and non isoSeq tags' do
        expect(well.sample_is_barcoded).to be true
      end

      it 'returns false if there is one aliquots and it has no tag' do
        pool = create(:pacbio_pool, :untagged, library_count: 1)
        empty_well = create(:pacbio_well, pools: [pool])
        expect(empty_well.sample_is_barcoded).to be false
      end

      it 'returns true if there is only one aliquots and it has a non isoSeq tag' do
        pool = create(:pacbio_pool)
        empty_well = create(:pacbio_well, pools: [pool])
        expect(empty_well.sample_is_barcoded).to be true
      end

      it 'returns false if the aliquots are tagged with a :hidden tag set (egh. IsoSeq)' do
        pool = create(:pacbio_pool, :hidden_tagged, library_count: 1)
        empty_well = create(:pacbio_well, pools: [pool])
        expect(empty_well.sample_is_barcoded).to be false
      end
    end

    describe '#bio_sample_name' do
      context 'when tag set is :default type' do
        it 'returns nothing if row type is well' do
          expect(well.bio_sample_name).to be_nil
        end

        it 'returns aliquot sample_name when well has libraries and row type is library' do
          aliquot = create(:pacbio_library).used_aliquots.first
          expect(aliquot.bio_sample_name).to eq aliquot.source.sample_name
        end
      end

      context 'when tag set is :hidden type (eg. IsoSeq)' do
        let(:library) { create(:pacbio_library, :hidden_tagged) }

        it 'returns well sample_names if row type is well' do
          pool = create(:pacbio_pool, :hidden_tagged, library_count: 1)
          empty_well = create(:pacbio_well, pools: [pool])
          expect(empty_well.bio_sample_name).to eq empty_well.sample_names
        end

        it 'returns nothing when well has libraries and row type is library' do
          aliquot = library.used_aliquots.first
          expect(aliquot.bio_sample_name).to eq ''
        end
      end
    end

    describe '#formatted_bio_sample_name' do
      context 'when tag set is :default type' do
        it 'returns nothing if row type is well' do
          expect(well.formatted_bio_sample_name).to be_nil
        end
      end

      context 'when tag set is :hidden type (eg. IsoSeq)' do
        let(:request) { create(:pacbio_request, sample: create(:sample, name: 'test:A1')) }
        let(:library) { create(:pacbio_library, :hidden_tagged, request:) }

        it 'returns dash separated sample_names if row type is well' do
          well = create(:pacbio_well, libraries: [library])
          expect(well.formatted_bio_sample_name).to eq well.sample_names.gsub(':', '-')
        end
      end
    end

    context 'show_row_per_sample?' do
      it 'returns true if all well aliquots are tagged' do
        expect(well.show_row_per_sample?).to be true
      end

      it 'returns false if there is one library and it has no tag' do
        pool = create(:pacbio_pool, :untagged, library_count: 1)
        empty_well = create(:pacbio_well, pools: [pool])
        expect(empty_well.show_row_per_sample?).to be false
      end

      it 'returns true if there is only one library and it has a tag' do
        pool = create(:pacbio_pool)
        empty_well = create(:pacbio_well, pools: [pool])
        expect(empty_well.show_row_per_sample?).to be true
      end

      it 'returns true if at least one of the well aliquots are tagged' do
        well.pools.first.used_aliquots << create(:aliquot, tag: create(:tag), source: create(:pacbio_library))
        expect(well.show_row_per_sample?).to be true
      end

      it 'returns nothing if the aliquots are tagged with a :hidden tag set (egh. IsoSeq)' do
        pool = create(:pacbio_pool, :hidden_tagged, library_count: 3)
        empty_well = create(:pacbio_well, pools: [pool])
        expect(empty_well.show_row_per_sample?).to be false
      end
    end

    context 'tube_barcode' do
      it 'returns the first aliquots tube barcode in well' do
        expected = well.base_used_aliquots.first.used_by.tube.barcode
        expect(well.tube_barcode).to eq expected
      end
    end

    context 'same_barcodes_on_both_ends_of_sequence' do
      let(:well) { create(:pacbio_well, pools:) }

      context 'when the well contains tags' do
        let(:pools) { create_list(:pacbio_pool, 1, :tagged) }

        it 'returns true' do
          expect(well.same_barcodes_on_both_ends_of_sequence).to be true
        end
      end

      context 'when the well does not contain tags' do
        let(:pools) { create_list(:pacbio_pool, 1, :untagged) }

        it 'returns nil' do
          expect(well.same_barcodes_on_both_ends_of_sequence).to be_nil
        end
      end
    end

    context 'position_leading_zero' do
      it 'can have a position with a leading zero for sample sheet generation' do
        expect(build(:pacbio_well, row: 'B', column: '1').position_leading_zero).to eq('B01')
      end
    end

    context 'plate_well_position' do
      let(:plate) { build(:pacbio_plate, plate_number: 2) }
      let(:well) { create(:pacbio_well, plate:, row: 'B', column: '1') }

      it 'prefixes the well position with the plate number' do
        expect(well.plate_well_position).to eq('2_B01')
      end
    end

    context 'with pre-extension time' do
      let(:well) { create(:pacbio_well, pre_extension_time: 3) }

      it 'automation parameters is formatted properly' do
        expect(well.automation_parameters).to eq("ExtensionTime=double:#{well.pre_extension_time}|ExtendFirst=boolean:True")
      end
    end

    context 'without pre-extension time' do
      it 'automation parameters is blank' do
        expect(well.automation_parameters).to be_nil
      end
    end

    context 'pre-extension time 0' do
      let(:well) { create(:pacbio_well, pre_extension_time: 0) }

      it 'automation parameters is blank' do
        expect(well.automation_parameters).to be_nil
      end
    end
  end
end
