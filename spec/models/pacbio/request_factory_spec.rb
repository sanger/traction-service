# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::RequestFactory, type: :model, pacbio: true do
  let(:attributes) { [attributes_for(:sample).merge(attributes_for(:pacbio_request)), 
                      attributes_for(:sample).merge(attributes_for(:pacbio_request)),
                      attributes_for(:sample).merge(attributes_for(:pacbio_request))] }

  context '#initialise' do
    it 'creates an object for each given request' do
      factory = Pacbio::RequestFactory.new(attributes)
      expect(factory.requests.count).to eq(3)
      expect(factory.requests[0].requestable.tube).to be_present
    end

    it 'produces error messages if any of the resources are not valid' do
      attributes << {}
      factory = Pacbio::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end
  end
 
  context '#save' do
    it 'creates a request in a tube for each set of attributes if they are valid' do
      factory = Pacbio::RequestFactory.new(attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(Pacbio::Request.all.count).to eq(attributes.length)
      expect(Pacbio::Request.first.tube).to eq(attributes.first[:tube])
    end

    it 'doesnt create a sample if it already exists' do
      sample = create(:sample)
      attributes << sample.attributes.extract!('name', 'species', 'external_id').with_indifferent_access.merge(attributes_for(:pacbio_request))
      factory = Pacbio::RequestFactory.new(attributes)
      factory.save
      expect(Sample.count).to eq(4)
    end

    it 'does not create any samples if attributes are not valid' do
      attributes << attributes_for(:sample).except(:name).merge(attributes_for(:pacbio_request))
      factory = Pacbio::RequestFactory.new(attributes)
      expect(factory).not_to be_valid
      expect(factory.save).to be_falsey
      expect(Tube.all.count).to eq(0)
    end
  end
end
