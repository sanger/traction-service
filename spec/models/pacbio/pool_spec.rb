# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::Pool, :pacbio do
  subject(:pool) { build(:pacbio_pool, params) }

  before do
    # Create a default pacbio smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v10', default: true)
  end

  let(:libraries) { create_list(:pacbio_library, 5) }
  let(:params) { {} }

  it 'has a tube on validation' do
    pool.valid?
    expect(pool.tube).to be_a(Tube)
  end

  it 'can have many libraries' do
    pool = build(:pacbio_pool, libraries:)
    expect(pool.libraries).to eq(libraries)
  end

  it 'can have a template prep kit box barcode' do
    expect(pool.template_prep_kit_box_barcode).to be_present
  end

  it 'can have a volume' do
    expect(pool.volume).to be_present
  end

  it 'can have a concentration' do
    expect(pool.concentration).to be_present
  end

  it 'can have a insert size' do
    expect(pool.insert_size).to be_present
  end

  it 'is not valid unless there is at least one library' do
    expect(build(:pacbio_pool, libraries: [])).not_to be_valid
  end

  it 'is not valid unless all of the associated libraries are valid' do
    dodgy_library = build(:pacbio_library, volume: 'big')

    expect(build(:pacbio_pool, libraries: libraries + [dodgy_library])).not_to be_valid
  end

  describe '#valid?(:run_creation)' do
    subject { pool.valid?(:run_creation) }

    context 'when volume is nil' do
      let(:params) { { volume: nil } }

      it { is_expected.to be false }
    end

    context 'when concentration is nil' do
      let(:params) { { concentration: nil } }

      it { is_expected.to be false }
    end

    context 'when insert_size is nil' do
      let(:params) { { insert_size: nil } }

      it { is_expected.to be false }
    end

    context 'when template_prep_kit_box_barcode is nil' do
      let(:params) { { template_prep_kit_box_barcode: nil } }

      it { is_expected.to be false }
    end

    context 'when volume is 12.0' do
      let(:params) { { volume: 12.0 } }

      it { is_expected.to be true }
    end

    context 'when concentration is 12.0' do
      let(:params) { { concentration: 12.0 } }

      it { is_expected.to be true }
    end

    context 'when insert_size is 12.0' do
      let(:params) { { insert_size: 12.0 } }

      it { is_expected.to be true }
    end

    context 'when template_prep_kit_box_barcode is "1234"' do
      let(:params) { { template_prep_kit_box_barcode: '1234' } }

      it { is_expected.to be true }
    end
  end

  context 'when volume is nil' do
    let(:params) { { volume: nil } }

    it { is_expected.to be_valid }
  end

  context 'when volume is positive' do
    let(:params) { { volume: 23 } }

    it { is_expected.to be_valid }
  end

  context 'when volume is negative' do
    let(:params) { { volume: -23 } }

    it { is_expected.not_to be_valid }
  end

  context 'when volume is "a word"' do
    let(:params) { { volume: 'a word' } }

    it { is_expected.not_to be_valid }
  end

  context 'when concentration is nil' do
    let(:params) { { concentration: nil } }

    it { is_expected.to be_valid }
  end

  context 'when concentration is positive' do
    let(:params) { { concentration: 23 } }

    it { is_expected.to be_valid }
  end

  context 'when concentration is negative' do
    let(:params) { { concentration: -23 } }

    it { is_expected.not_to be_valid }
  end

  context 'when concentration is "a word"' do
    let(:params) { { concentration: 'a word' } }

    it { is_expected.not_to be_valid }
  end

  context 'when insert_size is nil' do
    let(:params) { { insert_size: nil } }

    it { is_expected.to be_valid }
  end

  context 'when insert_size is positive' do
    let(:params) { { insert_size: 23 } }

    it { is_expected.to be_valid }
  end

  context 'when insert_size is negative' do
    let(:params) { { insert_size: -23 } }

    it { is_expected.not_to be_valid }
  end

  context 'when insert_size is "a word"' do
    let(:params) { { insert_size: 'a word' } }

    it { is_expected.not_to be_valid }
  end

  describe '#library_attributes=' do
    context 'with new libraries' do
      let(:library_attributes) { attributes_for_list(:pacbio_library, 5, primary_aliquot: nil, used_aliquots: []) }

      it 'sets up libraries' do
        pool = build(:pacbio_pool, library_count: 0)
        pool.library_attributes = library_attributes
        expect(pool.libraries.length).to eq 5
      end
    end

    context 'with existing libraries' do
      let(:pool) { create(:pacbio_pool, library_count: 5) }
      let(:library_attributes) do
        pool.libraries.map do |library|
          library.attributes.merge(
            'template_prep_kit_box_barcode' => 'Updated'
          )
        end
      end

      it 'update existing libraries' do
        pool.library_attributes = library_attributes
        expect(pool.libraries.length).to eq 5
      end

      it 'changes library attributes' do
        pool.library_attributes = library_attributes
        expect(
          pool.libraries.map(&:template_prep_kit_box_barcode)
        ).to all eq 'Updated'
      end
    end
  end

  describe '#used_aliquot_attributes=' do
    before do
      Flipper.enable(:multiplexing_phase_2_aliquot)
    end

    context 'with new used aliquots' do
      let(:used_aliquots_attributes) { attributes_for_list(:aliquot, 5, aliquot_type: :derived, source: nil) }

      it 'sets up used aliquots' do
        pool = build(:pacbio_pool)
        pool.used_aliquots_attributes = used_aliquots_attributes
        expect(pool.used_aliquots.length).to eq 5
      end
    end

    context 'with existing used aliquots' do
      let(:pool) { create(:pacbio_pool, library_count: 5) }
      let(:used_aliquots_attributes) do
        pool.used_aliquots.map do |aliquot|
          aliquot.attributes.merge(
            'volume' => 100
          )
        end
      end

      it 'update existing used aliquots' do
        pool.used_aliquots_attributes = used_aliquots_attributes
        expect(pool.used_aliquots.length).to eq 5
      end

      it 'changes used aliquot attributes' do
        pool.used_aliquots_attributes = used_aliquots_attributes
        expect(
          pool.used_aliquots.map(&:volume)
        ).to all eq 100
      end
    end
  end

  context 'tags' do
    it 'is valid if there is a single library with no tag' do
      expect(build(:pacbio_pool, libraries: [build(:pacbio_library, tag: nil)])).to be_valid
    end

    it 'does not be valid if there are multiple libraries and any of them dont have tags' do
      untagged_library = build(:pacbio_library, tag: nil)

      expect(build(:pacbio_pool, libraries: libraries + [untagged_library])).not_to be_valid
    end

    it 'is not valid unless all of the tags are unique' do
      library_with_duplicate_tag = build(:pacbio_library, tag: libraries.first.tag)
      expect(build(:pacbio_pool,
                   libraries: libraries + [library_with_duplicate_tag])).not_to be_valid
    end
  end

  context 'wells' do
    it 'can have one or more' do
      pool = create(:pacbio_pool)
      pool.wells << create_list(:pacbio_well, 5)
      expect(pool.wells.count).to eq(5)
    end
  end

  describe '#sequencing_plates' do
    it 'when there is no run' do
      pool = create(:pacbio_pool)
      expect(pool.sequencing_plates).to be_empty
    end

    it 'when there is a single run' do
      plate = build(:pacbio_plate_with_wells, :pooled)
      create(:pacbio_run, plates: [plate])
      pool = plate.wells.first.pools.first
      expect(pool.sequencing_plates).to eq([plate])
    end

    it 'when there are multiple runs' do
      plate1 = build(:pacbio_plate)
      plate2 = build(:pacbio_plate)
      create(:pacbio_run, plates: [plate1])
      create(:pacbio_run, plates: [plate2])
      pool = create(:pacbio_pool)
      create(:pacbio_well, pools: [pool], plate: plate1)
      create(:pacbio_well, pools: [pool], plate: plate2)
      expect(pool.sequencing_plates).to eq([plate1, plate2])
    end
  end

  describe '#sequencing_runs' do
    it 'when there is no run' do
      pool = create(:pacbio_pool)
      expect(pool.sequencing_runs).to be_empty
    end

    it 'when there is a single run' do
      plate = build(:pacbio_plate_with_wells, :pooled)
      create(:pacbio_run, plates: [plate])
      pool = plate.wells.first.pools.first
      expect(pool.sequencing_runs).to eq([plate.run])
    end

    it 'when there are multiple runs' do
      plate1 = build(:pacbio_plate)
      plate2 = build(:pacbio_plate)
      create(:pacbio_run, plates: [plate1])
      create(:pacbio_run, plates: [plate2])
      pool = create(:pacbio_pool)
      create(:pacbio_well, pools: [pool], plate: plate1)
      create(:pacbio_well, pools: [pool], plate: plate2)
      expect(pool.sequencing_runs).to eq([plate1.run, plate2.run])
    end
  end
end
