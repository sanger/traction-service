# frozen_string_literal: true

require 'rails_helper'

# These tests may end up being redundant but we need to make sure existing validations still work
# when this work is merged with yaml file for validations it would be better to load those
# validations rather than setting them here
# Make sure there is a default version to be able to create a run
RSpec.describe Pacbio::Well, pacbio: true do
  let!(:version10) { create(:pacbio_smrt_link_version, name: 'v10', default: true) }
  let!(:version11) { create(:pacbio_smrt_link_version, name: 'v11') }
  let!(:version12_revio) { create(:pacbio_smrt_link_version, name: 'v12_revio') }
  let!(:plate_v10) { create(:pacbio_plate, run: create(:pacbio_run, smrt_link_version: version10)) }

  before do
    # v10 and v11 validations
    create(:pacbio_smrt_link_option, key: :movie_time, validations: { presence: {}, numericality: { greater_than_or_equal_to: 0.1, less_than_or_equal_to: 30 } }, smrt_link_versions: [version10, version11])
    create(:pacbio_smrt_link_option, key: :binding_kit_box_barcode, validations: { presence: {} }, smrt_link_versions: [version10, version11])
    create(:pacbio_smrt_link_option, key: :on_plate_loading_concentration, validations: { presence: {} }, smrt_link_versions: [version10, version11])
    create(:pacbio_smrt_link_option, key: :pre_extension_time, validations: { numericality: { allow_blank: true } }, smrt_link_versions: [version10, version11])
    create(:pacbio_smrt_link_option, key: :loading_target_p1_plus_p2, validations: { numericality: { allow_blank: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1 } }, smrt_link_versions: [version10, version11])
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

  context 'movie time' do
    it 'must be present' do
      expect(build(:pacbio_well, plate: plate_v10, movie_time: nil)).not_to be_valid
    end

    it 'can be a decimal' do
      expect(build(:pacbio_well, movie_time: 0.2).movie_time).to eq(0.2)
    end

    it 'must be within range' do
      expect(build(:pacbio_well, plate: plate_v10, movie_time: 15)).to be_valid
      expect(build(:pacbio_well, plate: plate_v10, movie_time: 31)).not_to be_valid
      expect(build(:pacbio_well, plate: plate_v10, movie_time: 0)).not_to be_valid
    end
  end

  context 'insert size' do
    let(:pools)     { create_list(:pacbio_pool, 2) }
    let(:well)      { create(:pacbio_well, pools:) }

    it 'gest the fragment size of the first pool in the well' do
      expect(well.pools[0].insert_size).to eq(well.insert_size)
    end
  end

  it 'must have an on plate loading concentration' do
    expect(build(:pacbio_well, on_plate_loading_concentration: nil)).not_to be_valid
  end

  context 'position' do
    it 'can have a position' do
      expect(build(:pacbio_well, row: 'B', column: '1').position).to eq('B1')
    end
  end

  it 'must have to a plate' do
    expect(build(:pacbio_well, plate: nil)).not_to be_valid
  end

  it 'must have a binding kit box barcode' do
    expect(build(:pacbio_well, binding_kit_box_barcode: nil)).not_to be_valid
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
      expect(well).to be_pools
    end

    it 'no pools' do
      well = create(:pacbio_well)
      expect(well).not_to be_pools
    end
  end

  context 'pre-extension time' do
    it 'is not required' do
      expect(create(:pacbio_well, pre_extension_time: nil)).to be_valid
    end

    it 'can be set' do
      well = build(:pacbio_well, pre_extension_time: 2)
      expect(well.pre_extension_time).to eq(2)
    end

    it 'can be a decimal' do
      well = build(:pacbio_well, pre_extension_time: 2.5)
      expect(well).to be_valid
    end
  end

  context 'loading target p1 plus p2' do
    it 'is not required' do
      expect(build(:pacbio_well, loading_target_p1_plus_p2: nil)).to be_valid
    end

    it 'can be a decimal' do
      expect(build(:pacbio_well,
                   loading_target_p1_plus_p2: 0.5).loading_target_p1_plus_p2).to eq(0.5)
    end

    it 'must be within range' do
      expect(build(:pacbio_well, loading_target_p1_plus_p2: 0.45)).to be_valid
      expect(build(:pacbio_well, loading_target_p1_plus_p2: 72)).not_to be_valid
      expect(build(:pacbio_well, loading_target_p1_plus_p2: 0)).to be_valid
    end
  end

  context 'libraries' do
    let(:libraries) { create_list(:pacbio_library, 5, :tagged) }
    let(:pools)     { create_list(:pacbio_pool, 2, libraries:) }
    let(:well)      { create(:pacbio_well, pools:) }

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
      expect(sample_names.first).to eq(well.libraries.first.request.sample_name)

      sample_names = well.sample_names(',').split(',')
      expect(sample_names.length).to eq(2)
      expect(sample_names.first).to eq(well.libraries.first.request.sample_name)
    end

    it 'can return a list of tags' do
      tag_ids = well.libraries.collect(&:tag_id)
      expect(well.tags).to eq(tag_ids)
    end
  end

  context 'sample sheet mixin' do
    let(:well) { create(:pacbio_well) }

    it 'includes the Sample Sheet mixin' do
      expect(well.same_barcodes_on_both_ends_of_sequence).to be true
    end
  end

  context 'template prep kit box barcode' do
    let(:well) { create(:pacbio_well_with_pools) }

    it 'returns the well pools template_prep_kit_box_barcode' do
      expected = well.pools.first.template_prep_kit_box_barcode
      expect(well.template_prep_kit_box_barcode).to eq expected
    end
  end

  context 'collection?' do
    let(:well) { create(:pacbio_well) }

    it 'will always be true' do
      expect(well).to be_collection
    end
  end

  context 'Smrt Link Options' do
    let(:well)  { create(:pacbio_well) }
    let(:generate_in) { Pacbio::GENERATE }
    let(:yes_no) { Pacbio::YES_NO }
    let(:true_false) { Pacbio::TRUE_FALSE }

    it 'will include the relevant options' do
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

    context 'v10' do
      let(:well) { build(:pacbio_well, plate: plate_v10) }

      before do
        create(:pacbio_smrt_link_option, key: 'generate_hifi', validations: { presence: {}, inclusion: { in: generate_in } }, smrt_link_versions: [version10])
        create(:pacbio_smrt_link_option, key: 'ccs_analysis_output', validations: { presence: {}, inclusion: { in: yes_no } }, smrt_link_versions: [version10])
      end

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
      let(:well) { build(:pacbio_well, plate: create(:pacbio_plate, run: create(:pacbio_run, smrt_link_version: version11))) }

      before do
        create(:pacbio_smrt_link_option, key: 'demultiplex_barcodes', validations: { presence: {}, inclusion: { in: generate_in } }, smrt_link_versions: [version11])
        create(:pacbio_smrt_link_option, key: 'ccs_analysis_output_include_low_quality_reads', validations: { presence: {}, inclusion: { in: yes_no } }, smrt_link_versions: [version11])
        create(:pacbio_smrt_link_option, key: 'ccs_analysis_output_include_kinetics_information', validations: { presence: {}, inclusion: { in: yes_no } }, smrt_link_versions: [version11])
      end

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
      # build the well with the smrt_link version 12 revio
      let(:well) { build(:pacbio_well, plate: create(:pacbio_plate, run: create(:pacbio_run, smrt_link_version: version12_revio))) }

      # before do - create all the version12_revio specific options in here
      before do
      create(:pacbio_smrt_link_option, key: 'movie_acquisition_time', validations: { presence: {}, numericality: { greater_than_or_equal_to: 0.1, less_than_or_equal_to: 30 } }, smrt_link_versions: [version12_revio])
      create(:pacbio_smrt_link_option, key: 'include_base_kinetics', validations: { presence: {}, inclusion: { in: true_false } }, smrt_link_versions: [version12_revio])
      create(:pacbio_smrt_link_option, key: 'library_concentration', validations: { presence: {} }, smrt_link_versions: [version12_revio])
      create(:pacbio_smrt_link_option, key: 'polymerase_kit', validations: { presence: {} }, smrt_link_versions: [version12_revio])
      end

      context 'Movie acquisition time' do
        it 'must be present' do
          well.movie_acquisition_time = nil
          expect(well).not_to be_valid
        end
    
        it 'can be a decimal' do
          well.movie_acquisition_time = 0.2
          expect(well.movie_acquisition_time).to eq(0.2)
        end
    
        describe 'must be within range' do
          it 'is within range' do
          expect(well.movie_acquisition_time = 15).to eq(15)
          end

          it 'is above range' do
            well.movie_acquisition_time = 31
            expect(well).not_to be_valid
          end

          it 'is below range' do
            well.movie_acquisition_time = 0
            expect(well).not_to be_valid
          end
        end
      end

      context 'Include base kinetics' do
        it 'must be present' do
          well.include_base_kinetics = nil
          expect(well).not_to be_valid
        end

        it 'must be a valid value' do
          true_false.each do |option|
            well.include_base_kinetics = option
            expect(well).to be_valid
          end

          well.include_base_kinetics = 'junk'
          expect(well).not_to be_valid
        end
      end
      
      context 'Library concentration' do
        it 'must have a library concentration' do
          well.library_concentration = nil
          expect(well).not_to be_valid
        end
      end

      context 'Polymerase kit' do
        it 'must have a polymerase kit' do
          well.polymerase_kit = nil
          expect(well).not_to be_valid
        end
      end
    end
  end
end
