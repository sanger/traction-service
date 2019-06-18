# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SampleFactory, type: :model do
  let(:attributes) { [attributes_for(:sample), attributes_for(:sample), attributes_for(:sample)] }

  context '#initialise' do
    it 'creates an object for each given sample' do
      factory = SampleFactory.new(attributes)
      expect(factory.samples.count).to eq(3)
      expect(factory.samples[0].tube).to be_present
    end

    it 'produces error messages if any of the resources are not valid' do
      attributes << {}
      factory = SampleFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages[0]).to eq("Name can\'t be blank")
      expect(factory.errors.full_messages[1]).to eq("External can\'t be blank")
      expect(factory.errors.full_messages[2]).to eq("External study can\'t be blank")
      expect(factory.errors.full_messages[3]).to eq("Species can\'t be blank")
      expect(factory.errors.full_messages.length).to eq(4)
    end
  end

  context '#save' do
    it 'creates a sample in a tube for each set of attributes if they are valid' do
      factory = SampleFactory.new(attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(Sample.all.count).to eq(attributes.length)
      expect(Sample.first.tube).to eq(attributes.first[:tube])
    end

    it 'does not create any samples if attributes are not valid' do
      attributes << {}
      factory = SampleFactory.new(attributes)
      expect(factory).not_to be_valid
      expect(factory.save).to be_falsey
      expect(Tube.all.count).to eq(0)
    end
  end
end
