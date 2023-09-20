# frozen_string_literal: true

require 'rails_helper'

shared_examples_for 'requestor factory' do
  let(:request_model) { described_class.request_model.to_s.split('::').join('_').downcase }

  describe '#initialize' do
    it 'creates an object for each given request' do
      factory = described_class.new(attributes)
      expect(factory.requests.count).to eq(3)
    end

    it 'produces error messages if any of the resources are not valid' do
      attributes << {}
      factory = described_class.new(attributes)
      expect(factory).not_to be_valid
      expect(factory.errors.full_messages).not_to be_empty
    end
  end

  describe '#save' do
    it 'creates a request in a tube for each set of attributes if they are valid' do
      factory = described_class.new(attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(described_class.request_model.count).to eq(attributes.length)
      expect(described_class.request_model.first.tube).to be_present
    end

    it 'sets the barcode on the tube if it is provided' do
      expected_barcodes = attributes.pluck(:barcode)
      next unless expected_barcodes.all?(&:present?)

      factory = described_class.new(attributes)
      expect(factory.save).to be_truthy
      tube_barcodes = described_class.request_model.all.map { |r| r.tube.barcode }
      expect(tube_barcodes).to match_array(expected_barcodes)
    end

    it 'generates the barcode on the tube if it is not provided' do
      expected_barcodes = attributes.map { |attribute| attribute.dig(:library, :barcode) }
      next if expected_barcodes.all?(&:present?)

      factory = described_class.new(attributes)
      expect(factory.save).to be_truthy
      tube_barcodes = described_class.request_model.all.map { |r| r.tube.barcode }
      expect(tube_barcodes).to all be_present
    end

    it 'has some requestables' do
      factory = Pacbio::RequestFactory.new(attributes)
      factory.save
      expect(factory.requestables.count).to eq(3)
    end

    it 'doesn\'t create a sample if it already exists' do
      existing_sample = attributes_for(:sample)
      create(:sample, existing_sample)

      attributes << { sample: existing_sample, request: attributes_for(request_model) }
      factory = described_class.new(attributes)
      expect { factory.save }.to change(Sample, :count).by(3)
    end

    it 'does not create any samples if attributes are not valid' do
      attributes << {
        request: attributes_for(request_model),
        sample: attributes_for(:sample).except(:name)
      }
      factory = described_class.new(attributes)
      expect(factory).not_to be_valid
      expect(factory.save).to be_falsey
      expect(Tube.count).to eq(0)
    end
  end
end
