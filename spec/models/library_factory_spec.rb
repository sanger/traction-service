require 'rails_helper'

RSpec.describe LibraryFactory, type: :model do
  let(:sample) { create(:sample)}
  let(:attributes) { [{ state: 'pending', sample_id: sample.id }]}

  context '#initialise' do
    it 'creates an object for each given library' do
      factory = LibraryFactory.new(attributes)
      expect(factory.libraries.count).to eq(1)
    end

    it 'produces error messages if any of the libraries are not valid' do
      attributes << {}
      factory = LibraryFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages[0]).to eq("Sample must exist")
      expect(factory.errors.full_messages.length).to eq(1)
    end
  end

  context '#save' do
    it 'creates a library for each set of attributes if they are valid' do
      factory = LibraryFactory.new(attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(Library.all.count).to eq(attributes.length)
    end
  end

end
