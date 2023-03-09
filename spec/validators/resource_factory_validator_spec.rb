# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ResourceFactoryValidator' do
  describe '#validate' do
    let(:library_type) { create(:library_type, :ont) }
    let(:data_type) { create(:data_type, :ont) }

    let(:resource_factory) { build(:reception_resource_factory, request_attributes:) }
    let(:validator) { ResourceFactoryValidator.new }

    context 'valid' do
      let(:request_attributes) do
        [{
          request: attributes_for(:ont_request).merge(
            library_type: library_type.name,
            data_type: data_type.name
          ),
          sample: attributes_for(:sample, name: 'sample1'),
          container: { type: 'tubes', barcode: 'NT1' }
        }]
      end
    
      before do
        validator.validate(resource_factory)
      end

      it 'does not add an error to the record' do
        expect(resource_factory).to be_valid
      end
    end
    context 'invalid' do
      let(:request_attributes) do
        [{
          request: attributes_for(:ont_request).merge(
            library_type: library_type.name,
            data_type: data_type.name
          ),
          sample: attributes_for(:sample, name: nil),
          container: { type: 'tubes', barcode: 'NT1' }
        }]
      end
    
      before do
        validator.validate(resource_factory)
      end

      it 'does add an error to the record' do
        expect(resource_factory).to be_invalid
        expect(resource_factory.errors.count).to eq(2)
      end
    end
  end
end
