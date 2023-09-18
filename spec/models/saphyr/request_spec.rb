# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Saphyr::Request, :saphyr do
  let(:model) { described_class.to_s.split('::').join('_').downcase }

  it 'can have many libraries' do
    request = create(:saphyr_request)
    request.libraries << create_list(:saphyr_library, 5)
    expect(request.libraries.count).to eq(5)
  end

  module_ = described_class.to_s.deconstantize.constantize

  it 'will have a sample name' do
    expect(create(model).sample_name).to be_present
  end

  module_.required_request_attributes.each do |attribute|
    it "is not valid without #{attribute.to_s.gsub('_', ' ')}" do
      factory = build(model)
      factory.send("#{attribute}=", nil)
      expect(factory).not_to be_valid
    end
  end

  describe '#source_identifier' do
    let(:request) { build(model) }

    context 'when from a plate' do
      before do
        create(:plate_with_wells_and_requests,
               row_count: 1, column_count: 1, barcode: 'BC12',
               requests: [request])
      end

      it 'returns the plate barcode and well' do
        expect(request.source_identifier).to eq('BC12:A1')
      end
    end

    context 'when from a tube' do
      before do
        create(:tube, requests: [request], barcode: 'TUB1')
      end

      it 'returns the plate barcode and well' do
        expect(request.source_identifier).to eq('TUB1')
      end
    end
  end
end
