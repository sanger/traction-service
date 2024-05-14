# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::Pool, :pacbio do
  subject(:pool) { build(:pacbio_pool, params) }

  before do
    # Create a default pacbio smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v10', default: true)
  end

  let(:used_aliquots) { create_list(:aliquot, 5, source: build(:pacbio_library), aliquot_type: :derived) }
  let(:params) { {} }

  it 'has a tube on validation' do
    pool.valid?
    expect(pool.tube).to be_a(Tube)
  end

  it 'can have many libraries through used_aliquots' do
    pool = build(:pacbio_pool, library_count: 0)
    expect(pool.libraries).to be_empty
    pool.used_aliquots = build_list(:aliquot, 5, source: build(:pacbio_library), aliquot_type: :derived)
    pool.save
    expect(pool.libraries.length).to eq(5)
  end

  it 'can have many requests through used_aliquots' do
    pool = build(:pacbio_pool, library_count: 0)
    expect(pool.requests).to be_empty
    pool.used_aliquots = build_list(:aliquot, 5, source: build(:pacbio_request), aliquot_type: :derived)
    pool.save
    expect(pool.requests.length).to eq(5)
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

  it 'is not valid unless there is at least one used_aliquot' do
    expect(build(:pacbio_pool, used_aliquots: [])).not_to be_valid
  end

  it 'is not valid unless all of the associated used_aliquots are valid' do
    dodgy_aliquot = build(:aliquot, volume: 'big', source: build(:pacbio_library), aliquot_type: :derived)

    expect(build(:pacbio_pool, used_aliquots: used_aliquots + [dodgy_aliquot])).not_to be_valid
  end

  it 'is not valid when using an invalid amount of volume from a library' do
    Flipper.enable(:dpl_1072_check_library_volume_in_pools)

    libraries = create_list(:pacbio_library, 3, volume: 100)
    # Pool with 3 libraries: 2 invalid ones and one valid
    pool = build(:pacbio_pool, used_aliquots: [
      create(:aliquot, source: libraries[0], volume: 101, aliquot_type: :derived),
      create(:aliquot, source: libraries[1], volume: 101, aliquot_type: :derived),
      create(:aliquot, source: libraries[2], volume: 99, aliquot_type: :derived)
    ])
    expect(pool).not_to be_valid
    expect(pool.errors[:base][0]).to eq("Insufficient volume available for #{libraries[0].tube.barcode},#{libraries[1].tube.barcode}")

    Flipper.disable(:dpl_1072_check_library_volume_in_pools)
  end

  it 'is valid when using a valid amount of volume from a library' do
    Flipper.enable(:dpl_1072_check_library_volume_in_pools)

    library = create(:pacbio_library, volume: 100)
    pool = build(:pacbio_pool, used_aliquots: [build(:aliquot, source: library, volume: 100, aliquot_type: :derived)])
    expect(pool).to be_valid

    Flipper.disable(:dpl_1072_check_library_volume_in_pools)
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

  describe '#used_aliquot_attributes=' do
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
    it 'is valid if there is a single used_aliquot with no tag' do
      expect(build(:pacbio_pool, used_aliquots: [build(:aliquot, tag: nil)])).to be_valid
    end

    it 'is not valid if there are multiple used_aliquots and none of them dont have tags' do
      untagged_aliquot = build(:aliquot, tag: nil)

      expect(build(:pacbio_pool, used_aliquots: used_aliquots + [untagged_aliquot])).not_to be_valid
    end

    it 'is not valid unless all of the tags are unique' do
      used_aliquot_with_duplicate_tag = build(:aliquot, tag: used_aliquots.first.tag)
      expect(build(:pacbio_pool,
                   used_aliquots: used_aliquots + [used_aliquot_with_duplicate_tag])).not_to be_valid
    end
  end

  context 'wells' do
    it 'can have one or more' do
      pool = create(:pacbio_pool)
      create_list(:pacbio_well, 5, pools: [pool])
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
      create(:pacbio_generic_run, plates: [plate])
      pool = plate.wells.first.pools.first
      expect(pool.sequencing_plates).to eq([plate])
    end

    it 'when there are multiple runs' do
      plate1 = build(:pacbio_plate)
      plate2 = build(:pacbio_plate)
      create(:pacbio_generic_run, plates: [plate1])
      create(:pacbio_generic_run, plates: [plate2])
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
      create(:pacbio_generic_run, plates: [plate])
      pool = plate.wells.first.pools.first
      expect(pool.sequencing_runs).to eq([plate.run])
    end

    it 'when there are multiple runs' do
      plate1 = build(:pacbio_plate)
      plate2 = build(:pacbio_plate)
      create(:pacbio_generic_run, plates: [plate1])
      create(:pacbio_generic_run, plates: [plate2])
      pool = create(:pacbio_pool)
      create(:pacbio_well, pools: [pool], plate: plate1)
      create(:pacbio_well, pools: [pool], plate: plate2)
      expect(pool.sequencing_runs).to eq([plate1.run, plate2.run])
    end
  end
end
