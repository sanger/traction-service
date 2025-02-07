# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Aliquot do
  context 'uuidable aliquot' do
    let(:uuidable_model) { :aliquot }

    it_behaves_like 'uuidable'
  end

  it 'is invalid without volume' do
    expect(build(:aliquot, volume: nil)).not_to be_valid
  end

  it 'is invalid without concentration' do
    expect(build(:aliquot, concentration: nil)).not_to be_valid
  end

  it 'is invalid without template_prep_kit_box_barcode' do
    expect(build(:aliquot, template_prep_kit_box_barcode: nil)).not_to be_valid
  end

  it 'is valid without an insert_size' do
    # Insert size may not be known at the time of creation so we don't validate it
    expect(build(:aliquot, insert_size: nil)).to be_valid
  end

  it 'is valid without volume, concentration, template_prep_kit_box_barcode and insert_size if source is a Pacbio::Request and its a primary aliquot' do
    expect(build(:aliquot, volume: nil, concentration: nil, template_prep_kit_box_barcode: nil, insert_size: nil, source: build(:pacbio_request), aliquot_type: :primary)).to be_valid
  end

  it 'is invalid if volume is not a positive number' do
    expect(build(:aliquot, volume: 'a word')).not_to be_valid
    expect(build(:aliquot, volume: '-1')).not_to be_valid
  end

  it 'is invalid if concentration is not a positive number' do
    expect(build(:aliquot, concentration: 'a word')).not_to be_valid
    expect(build(:aliquot, concentration: '-1')).not_to be_valid
  end

  it 'is invalid if insert_size is not a positive number' do
    expect(build(:aliquot, insert_size: 'a word')).not_to be_valid
    expect(build(:aliquot, insert_size: '-1')).not_to be_valid
  end

  it 'has a valid list of states' do
    expect(described_class.states).to eq({ 'created' => 0, 'used' => 1 })
  end

  it 'is invalid without a state' do
    expect { create(:aliquot, state: nil) }.to raise_error(ActiveRecord::NotNullViolation)
  end

  it 'has a valid list of aliquot_types' do
    expect(described_class.aliquot_types).to eq({ 'primary' => 0, 'derived' => 1 })
  end

  it 'is invalid without an aliquot_type' do
    expect { create(:aliquot, aliquot_type: nil) }.to raise_error(ActiveRecord::NotNullViolation)
  end

  it 'can have a tag' do
    tag = create(:tag)
    expect(build(:aliquot, tag:).tag).to eq(tag)
  end

  context 'uuidable' do
    let(:uuidable_model) { :pacbio_library }

    it_behaves_like 'uuidable'
  end

  it 'is invalid without a source' do
    aliquot = build(:aliquot, source: nil)
    expect(aliquot).not_to be_valid
    expect(aliquot.errors[:source]).to include('must exist')
  end

  it 'can have a library through the used_by relation' do
    pacbio_library = create(:pacbio_library)
    aliquot = build(:aliquot, used_by: pacbio_library)
    expect(aliquot).to be_valid
    expect(aliquot.used_by).to eq(pacbio_library)
  end

  it 'returns true if used_by is an instance of the specified class' do
    pacbio_library = create(:pacbio_library)
    aliquot = build(:aliquot, used_by: pacbio_library)
    expect(aliquot.used_by_is_a?(Pacbio::Library)).to be true
  end

  it 'returns false if used_by is not an instance of the specified class' do
    pacbio_library = create(:pacbio_library)
    aliquot = build(:aliquot, used_by: pacbio_library)
    expect(aliquot.used_by_is_a?(Pacbio::Pool)).to be false
  end

  describe '#tag_set' do
    it 'returns the tag set for the aliquot' do
      tag = create(:tag)
      aliquot = create(:aliquot, tag:)
      expect(aliquot.tag_set).to eq(tag.tag_set)
    end

    it 'returns a NullTagSet if the tag set is nil' do
      aliquot = create(:aliquot, tag: nil)
      expect(aliquot.tag_set).to be_a(NullTagSet)
    end
  end

  describe '#valid?(:run_creation)' do
    subject { build(:aliquot, params).valid?(:run_creation) }

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

  describe '#publishable' do
    before do
      Pacbio::SmrtLinkVersion.find_by(name: 'v13_sequel_iie') || create(:pacbio_smrt_link_version, name: 'v13_sequel_iie', default: true)
    end

    it 'returns all of the publishable aliquots' do
      # 3 aliquots are publishable
      create(:pacbio_pool)

      # 2 aliquots are publishable
      library = create(:pacbio_library)

      # 5 aliquots are publishable
      build(:pacbio_pool, used_aliquots: [build(:aliquot, source: library, volume: 100, aliquot_type: :derived)])
      wells = [build(:pacbio_well, row: 'A', column: '1', pools: [create(:pacbio_pool)])]
      create(:pacbio_revio_run, plates: [build(:pacbio_plate, wells:)])

      expect(described_class.publishable.count).to eq(10)
    end
  end

  context 'sample sheet behaviour' do
    before do
      # Create a default pacbio smrt link version for pacbio runs.
      create(:pacbio_smrt_link_version, name: 'v12_sequel_iie', default: true)
    end

    describe '#tagged?' do
      it 'returns true if the aliquot has a tag' do
        aliquot = create(:aliquot, tag: create(:tag))
        expect(aliquot.tagged?).to be true
      end

      it 'returns false if the aliquot does not have a tag' do
        aliquot = create(:aliquot, tag: nil)
        expect(aliquot.tagged?).to be false
      end

      it 'returns false if the aliquot has a hidden tag set' do
        aliquot = create(:aliquot, tag: create(:hidden_tag))
        expect(aliquot.tagged?).to be false
      end
    end

    describe '#collection?' do
      let(:aliquot) { create(:aliquot) }

      it 'always be false' do
        expect(aliquot).not_to be_collection
      end
    end

    describe '#barcode_name' do
      let(:library_count) { 1 }
      let(:empty_well) { create(:pacbio_well, pools: [pool]) }

      context 'when the well has one aliquot' do
        let(:pool) { create(:pacbio_pool, :tagged, library_count:) }

        it 'returns a string of aliquot tags' do
          tag_group_id = empty_well.base_used_aliquots.first.tag.group_id
          expected = "#{tag_group_id}--#{tag_group_id}"
          expect(empty_well.base_used_aliquots.last.barcode_name).to eq expected
        end
      end

      context 'when the aliquots are tagged with a :hidden tag set (egh. IsoSeq)' do
        let(:pool) { create(:pacbio_pool, :hidden_tagged, library_count:) }

        it 'returns nothing' do
          expect(empty_well.base_used_aliquots.last.barcode_name).to be_nil
        end
      end
    end

    describe '#adapter' do
      context 'when the aliquot is tagged' do
        let(:well) { create(:pacbio_well, pool_count: 1) }

        it 'returns the tag group id' do
          aliquot = well.base_used_aliquots.first
          expect(aliquot.adapter).to eq aliquot.tag.group_id
        end
      end

      context 'when the aliquot is not tagged' do
        let(:pool) { create(:pacbio_pool, :untagged, library_count: 1) }
        let(:well) { create(:pacbio_well, pools: [pool]) }

        it 'returns nil' do
          aliquot = well.base_used_aliquots.first
          expect(aliquot.adapter).to be_nil
        end
      end
    end

    describe '#bio_sample_name' do
      context 'when the sample sheet behaviour is default' do
        it 'returns the source sample name for a aliquot from a library' do
          library = create(:pacbio_library)
          aliquot = create(:aliquot, source: library)
          expect(aliquot.bio_sample_name).to eq(library.sample_name)
        end
      end

      context 'when the sample sheet behaviour is hidden' do
        it 'returns an empty string' do
          library = create(:pacbio_library)
          aliquot = create(:aliquot, tag: create(:hidden_tag), source: library)
          expect(aliquot.bio_sample_name).to eq('')
        end
      end
    end

    describe '#formatted_bio_sample_name' do
      context 'when the sample sheet behaviour is default' do
        it 'returns the source sample name for a aliquot from a library' do
          request = create(:pacbio_request, sample: create(:sample, name: 'test:A1'))
          library = create(:pacbio_library, request:)
          aliquot = create(:aliquot, source: library)
          expect(aliquot.formatted_bio_sample_name).to eq(library.sample_name.gsub(':', '-'))
        end
      end

      context 'when the sample sheet behaviour is hidden' do
        it 'returns an empty string' do
          library = create(:pacbio_library)
          aliquot = create(:aliquot, tag: create(:hidden_tag), source: library)
          expect(aliquot.formatted_bio_sample_name).to eq('')
        end
      end
    end
  end
end
