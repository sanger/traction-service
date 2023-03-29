# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Saphyr::RequestFactory, saphyr: true do
  let(:attributes) do
    [
      { sample: attributes_for(:sample), request: attributes_for(:saphyr_request) },
      { sample: attributes_for(:sample), request: attributes_for(:saphyr_request) },
      { sample: attributes_for(:sample), request: attributes_for(:saphyr_request) }
    ]
  end

  describe '#initialize' do
    it 'creates an object for each given request' do
      factory = described_class.new(attributes)
      expect(factory.requests.count).to eq(3)
    end

    it 'produces error messages if any of the resources are not valid' do
      attributes << { request: {}, sample: {} }
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
      expect(Saphyr::Request.count).to eq(attributes.length)
      expect(Saphyr::Request.first.tube).to be_present
    end

    it 'sets the barcode on the tube if it is provided' do
      expected_barcodes = attributes.pluck(:barcode)
      next unless expected_barcodes.all?(&:present?)

      factory = described_class.new(attributes)
      expect(factory.save).to be_truthy
      tube_barcodes = Saphyr::Request.all.map { |r| r.tube.barcode }
      expect(tube_barcodes).to match_array(expected_barcodes)
    end

    it 'has some requestables' do
      factory = described_class.new(attributes)
      factory.save
      expect(factory.requestables.count).to eq(3)
    end

    it 'doesn\'t create a sample if it already exists' do
      existing_sample = attributes_for(:sample)
      create(:sample, existing_sample)

      attributes << { sample: existing_sample, request: attributes_for(:saphyr_request) }
      factory = described_class.new(attributes)
      expect { factory.save }.to change(Sample, :count).by(3)
    end

    it 'does not create any samples if attributes are not valid' do
      attributes << {
        request: attributes_for(:saphyr_request),
        sample: attributes_for(:sample).except(:name)
      }
      factory = described_class.new(attributes)
      expect(factory).not_to be_valid
      expect(factory.save).to be_falsey
      expect(Tube.all.count).to eq(0)
    end

    it 'adds requestables validation message to errors if attributes are not valid' do
      attributes << {
        request: {},
        sample: attributes_for(:sample)
      }
      factory = described_class.new(attributes)
      expect(factory).not_to be_valid
      expect(factory.errors.messages).to include({ requestable: ['is invalid'],
                                                   external_study_id: ["can't be blank"] })
    end
  end
end
