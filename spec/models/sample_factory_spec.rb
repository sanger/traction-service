require 'rails_helper'

RSpec.describe SampleFactory, type: :model do

  let(:attributes) { [attributes_for(:sample), attributes_for(:sample), attributes_for(:sample)]}

  context '#initialise' do
    it 'creates an object for each given sample name' do
      factory = SampleFactory.new(attributes)
      expect(factory.samples.count).to eq(3)
    end

    it 'produces error messages if any of the resources are not valid' do
      attributes << {}
      factory = SampleFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages[0]).to eq("Name can\'t be blank")
      expect(factory.errors.full_messages[1]).to eq("Sequencescape request can\'t be blank")
      expect(factory.errors.full_messages[2]).to eq("Species can\'t be blank")
      expect(factory.errors.full_messages.length).to eq(3)
    end
  end

  context '#save' do
    it 'creates a sample for each set of attributes if they are valid' do
      factory = SampleFactory.new(attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(Sample.all.count).to eq(attributes.length)
    end
  end

end
