# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ont::Library, type: :model, ont: true do
  subject { build(:ont_library, params) }

  context 'material' do
    let(:material_model) { :ont_library }

    it_behaves_like 'material'
  end

  it 'must have a pool' do
    library = build(:ont_library, pool: nil)
    expect(library).not_to be_valid
  end

  context 'uuidable' do
    let(:uuidable_model) { :ont_library }

    it_behaves_like 'uuidable'
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

  it 'can have a kit barcode' do
    expect(build(:ont_library, kit_barcode: nil)).to be_valid
    expect(create(:ont_library).kit_barcode).to be_present
  end

  it 'can have a request' do
    request = build(:ont_request)
    expect(build(:ont_library, request:).request).to eq(request)
  end

  it 'can have a tag' do
    tag = build(:tag)
    expect(build(:ont_library, tag:).tag).to eq(tag)
  end

  it 'can have a tagset through tag' do
    tag = create(:ont_tag)

    expect(create(:ont_library, tag:).tag_set).to eq(tag.tag_set)
  end

  it 'can have a pool' do
    pool = build(:ont_pool)
    expect(build(:ont_library, pool:).pool).to eq(pool)
  end

  it 'can have a tube through pool' do
    pool = build(:ont_pool)
    expect(build(:ont_library, pool:).tube).to eq(pool.tube)
  end

  describe '#request' do
    let!(:library) { create(:ont_library, tag: create(:tag)) }

    it 'can have one' do
      expect(library.request).to be_present
    end

    it 'will not delete the requests when the library is deleted' do
      expect { library.destroy }.not_to change(Ont::Request, :count)
    end
  end

  context 'library' do
    let(:library_factory) { :ont_library }
    let(:library_model) { described_class }

    it_behaves_like 'library'
  end

  describe '#source_identifier' do
    let(:library) { create(:ont_library, :tagged) }

    context 'from a well' do
      before do
        create(:plate_with_wells_and_requests, pipeline: 'ont',
                                               row_count: 1, column_count: 1, barcode: 'BC12',
                                               requests: [library.request])
      end

      it 'returns the plate barcode and well' do
        expect(library.source_identifier).to eq('BC12:A1')
      end
    end

    context 'from a tube' do
      before do
        create(:tube_with_ont_request, requests: [library.request], barcode: 'TRAC-2-757')
      end

      it 'returns the plate barcode and well' do
        expect(library.source_identifier).to eq('TRAC-2-757')
      end
    end
  end
end
