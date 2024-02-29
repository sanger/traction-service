# frozen_string_literal: true

require 'rails_helper'

shared_examples_for 'requestor model' do
  let(:model) { described_class.to_s.split('::').join('_').downcase }

  module_ = described_class.to_s.deconstantize.constantize

  it 'has a sample name' do
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
        create(:tube, "#{module_.to_s.downcase}_requests": [request], barcode: 'TUB1')
      end

      it 'returns the plate barcode and well' do
        expect(request.source_identifier).to eq('TUB1')
      end
    end
  end
end
