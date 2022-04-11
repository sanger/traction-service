# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Saphyr::RequestFactory, type: :model, saphyr: true do
  let(:attributes) do
    [
      { sample: attributes_for(:sample), request: attributes_for(:saphyr_request) },
      { sample: attributes_for(:sample), request: attributes_for(:saphyr_request) },
      { sample: attributes_for(:sample), request: attributes_for(:saphyr_request) }
    ]
  end

  context '#initialize' do
    it 'creates an object for each given request' do
      factory = Saphyr::RequestFactory.new(attributes)
      expect(factory.requests.count).to eq(3)
    end

    it 'produces error messages if any of the resources are not valid' do
      attributes << {}
      factory = Saphyr::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end
  end

  context '#save' do
    it 'creates a request in a tube for each set of attributes if they are valid' do
      factory = Saphyr::RequestFactory.new(attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(Saphyr::Request.count).to eq(attributes.length)
      expect(Saphyr::Request.first.tube).to be_present
    end

    it 'sets the barcode on the tube if it is provided' do
      expected_barcodes = attributes.pluck(:barcode)
      next unless expected_barcodes.all?(&:present?)

      factory = Saphyr::RequestFactory.new(attributes)
      expect(factory.save).to be_truthy
      tube_barcodes = Saphyr::Request.all.map { |r| r.tube.barcode }
      expect(tube_barcodes).to contain_exactly(*expected_barcodes)
    end

    it 'has some requestables' do
      factory = Saphyr::RequestFactory.new(attributes)
      factory.save
      expect(factory.requestables.count).to eq(3)
    end

    it 'doesn\'t create a sample if it already exists' do
      existing_sample = attributes_for(:sample)
      create(:sample, existing_sample)

      attributes << { sample: existing_sample, request: attributes_for(:saphyr_request) }
      factory = Saphyr::RequestFactory.new(attributes)
      expect { factory.save }.to change(Sample, :count).by(3)
    end

    it 'does not create any samples if attributes are not valid' do
      attributes << {
        request: attributes_for(:saphyr_request),
        sample: attributes_for(:sample).except(:name)
      }
      factory = Saphyr::RequestFactory.new(attributes)
      expect(factory).not_to be_valid
      expect(factory.save).to be_falsey
      expect(Tube.all.count).to eq(0)
    end
  end

end

# require "rails_helper"

# shared_examples_for 'requestor factory' do

#   let(:request_model)   { described_class.request_model.to_s.split('::').join('_').downcase }

#   context '#initialize' do
#     it 'creates an object for each given request' do
#       factory = described_class.new(attributes)
#       expect(factory.requests.count).to eq(3)
#     end

#     it 'produces error messages if any of the resources are not valid' do
#       attributes << {}
#       factory = described_class.new(attributes)
#       expect(factory).to_not be_valid
#       expect(factory.errors.full_messages).to_not be_empty
#     end
#   end

#   context '#save' do
#     it 'creates a request in a tube for each set of attributes if they are valid' do
#       factory = described_class.new(attributes)
#       expect(factory).to be_valid
#       expect(factory.save).to be_truthy
#       expect(described_class.request_model.all.count).to eq(attributes.length)
#       expect(described_class.request_model.first.tube).to be_present
#     end

#     it 'sets the barcode on the tube if it is provided' do
#       expected_barcodes = attributes.pluck(:barcode)
#       next unless expected_barcodes.all?(&:present?)

#       factory = described_class.new(attributes)
#       expect(factory.save).to be_truthy
#       tube_barcodes = described_class.request_model.all.map { |r| r.tube.barcode }
#       expect(tube_barcodes).to contain_exactly(*expected_barcodes)
#     end

#     it 'generates the barcode on the tube if it is not provided' do
#       expected_barcodes = attributes.map { |attribute| attribute.dig(:library, :barcode) }
#       next if expected_barcodes.all?(&:present?)

#       factory = described_class.new(attributes)
#       expect(factory.save).to be_truthy
#       tube_barcodes = described_class.request_model.all.map { |r| r.tube.barcode }
#       expect(tube_barcodes).to all be_present
#     end

#     it 'has some requestables' do
#       factory = Pacbio::RequestFactory.new(attributes)
#       factory.save
#       expect(factory.requestables.count).to eq(3)
#     end

#     it 'doesn\'t create a sample if it already exists' do
#       existing_sample = attributes_for(:sample)
#       create(:sample, existing_sample)

#       attributes << { sample: existing_sample, request: attributes_for(request_model) }
#       factory = described_class.new(attributes)
#       expect { factory.save }.to change(Sample, :count).by(3)
#     end

#     it 'does not create any samples if attributes are not valid' do
#       attributes << {
#         request: attributes_for(request_model),
#         sample: attributes_for(:sample).except(:name)
#       }
#       factory = described_class.new(attributes)
#       expect(factory).not_to be_valid
#       expect(factory.save).to be_falsey
#       expect(Tube.all.count).to eq(0)
#     end
#   end

# end

