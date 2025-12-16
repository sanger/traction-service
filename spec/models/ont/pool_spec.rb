# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ont::Pool, :ont do
  subject(:pool) { build(:ont_pool, params) }

  let(:libraries) { create_list(:ont_library, 5) }
  let(:params) { {} }

  context 'uuidable' do
    let(:uuidable_model) { :ont_pool }

    it_behaves_like 'uuidable'
  end

  it 'has a tube on validation' do
    pool.valid?
    expect(pool.tube).to be_a(Tube)
  end

  it 'can set the tube barcode if given' do
    pool = create(:ont_pool, barcode: '123456')
    expect(pool.tube.barcode).to eq('123456')
  end

  it 'can have many libraries' do
    pool = build(:ont_pool, libraries:)
    expect(pool.libraries).to eq(libraries)
  end

  it 'can have a kit barcode' do
    expect(pool.kit_barcode).to be_present
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
    expect(build(:ont_pool, libraries: [])).not_to be_valid
  end

  it 'is not valid unless all of the associated libraries are valid' do
    dodgy_library = build(:ont_library, volume: 'big')

    expect(build(:ont_pool, libraries: libraries + [dodgy_library])).not_to be_valid
  end

  it 'can have a multi_pool_position' do
    multi_pool_position = create(:multi_pool_position, pool: pool)
    expect(pool.reload.multi_pool_position).to eq(multi_pool_position)
  end

  it 'can have a multi_pool' do
    multi_pool_position = create(:multi_pool_position, pool: pool)
    expect(pool.reload.multi_pool).to eq(multi_pool_position.multi_pool)
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
      let(:library_attributes) { attributes_for_list(:ont_library, 5) }

      it 'sets up libraries' do
        pool = build(:ont_pool, library_count: 0)
        pool.library_attributes = library_attributes
        expect(pool.libraries.length).to eq 5
      end
    end

    context 'with existing libraries' do
      let(:pool) { create(:ont_pool, library_count: 5) }
      let(:library_attributes) do
        pool.libraries.map do |library|
          library.attributes.merge(
            'kit_barcode' => 'Updated'
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
          pool.libraries.map(&:kit_barcode)
        ).to all eq 'Updated'
      end
    end
  end

  context 'tags' do
    it 'is valid if there is a single library with no tag' do
      expect(build(:ont_pool, libraries: [build(:ont_library, tag: nil)])).to be_valid
    end

    it 'is not valid if there are multiple libraries and any of them dont have tags' do
      untagged_library = build(:ont_library, tag: nil)

      expect(build(:ont_pool, libraries: libraries + [untagged_library])).not_to be_valid
    end

    it 'is not valid unless all of the tags are unique' do
      library_with_duplicate_tag = build(:ont_library, tag: libraries.first.tag)
      expect(build(:ont_pool,
                   libraries: libraries + [library_with_duplicate_tag])).not_to be_valid
    end
  end

  context 'calculate final library amount' do
    it 'is called when a pool is saved and calculates the correct final_library_amount' do
      pool = build(:ont_pool, concentration: 20.0, volume: 24, insert_size: 20000)
      expect(pool.final_library_amount).to be_nil
      pool.save
      expect(pool.final_library_amount).to eq(36.4)
    end

    it 'returns nil when concentration doesnt exist' do
      pool = create(:ont_pool, concentration: nil)
      expect(pool.final_library_amount).to be_nil
    end

    it 'returns nil when volume doesnt exist' do
      pool = create(:ont_pool, volume: nil)
      expect(pool.final_library_amount).to be_nil
    end

    it 'returns nil when insert size doesnt exist' do
      pool = create(:ont_pool, insert_size: nil)
      expect(pool.final_library_amount).to be_nil
    end

    it 'returns nil when the insert size is 0' do
      pool = create(:ont_pool, insert_size: 0)
      expect(pool.final_library_amount).to be_nil
    end
  end
end
