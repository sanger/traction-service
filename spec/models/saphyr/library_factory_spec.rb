# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Saphyr::LibraryFactory, :saphyr do
  let(:request) { create(:saphyr_request) }
  let(:saphyr_enzyme) { create(:saphyr_enzyme) }
  let(:attributes) do
    [{ state: 'pending', saphyr_request_id: request.id, saphyr_enzyme_id: saphyr_enzyme.id }]
  end

  describe '#initialise' do
    it 'creates an object for each given library' do
      factory = described_class.new(attributes)
      expect(factory.libraries.count).to eq(1)
    end

    it 'produces error messages if any of the libraries are not valid' do
      attributes << {}
      factory = described_class.new(attributes)
      expect(factory).not_to be_valid
      expect(factory.errors.full_messages[0]).to eq('Request must exist')
      expect(factory.errors.full_messages[1]).to eq('Enzyme must exist')
      expect(factory.errors.full_messages.length).to eq(2)
    end
  end

  describe '#save' do
    it 'creates a library in a tube for each set of attributes if they are valid' do
      factory = described_class.new(attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(Saphyr::Library.count).to eq(attributes.length)
      expect(Saphyr::Library.first.tube.materials.first).to eq(Saphyr::Library.first)
    end

    it 'does not create any libraries if attributes are not valid' do
      factory = described_class.new({})
      expect(factory).not_to be_valid
      expect(factory.save).to be_falsey
      expect(Saphyr::Library.count).to eq(0)
      expect(Tube.count).to eq(0)
    end
  end
end
