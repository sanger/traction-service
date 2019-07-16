require 'rails_helper'

RSpec.describe Saphyr::LibraryFactory, type: :model, saphyr: true do
  let(:request) { create(:saphyr_request)}
  let(:saphyr_enzyme) { create(:saphyr_enzyme)}
  let(:attributes) { [{ state: 'pending', saphyr_request_id: request.id, saphyr_enzyme_id: saphyr_enzyme.id }]}

  context '#initialise' do
    it 'creates an object for each given library' do
      factory = Saphyr::LibraryFactory.new(attributes)
      expect(factory.libraries.count).to eq(1)
      expect(factory.libraries[0].tube).to be_present
    end

    it 'produces error messages if any of the libraries are not valid' do
      attributes << {}
      factory = Saphyr::LibraryFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages[0]).to eq("Request must exist")
      expect(factory.errors.full_messages[1]).to eq("Enzyme must exist")
      expect(factory.errors.full_messages.length).to eq(2)
    end
  end

  context '#save' do
    it 'creates a library in a tube for each set of attributes if they are valid' do
      factory = Saphyr::LibraryFactory.new(attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(Saphyr::Library.all.count).to eq(attributes.length)
      expect(Saphyr::Library.first.tube).to eq(attributes.first[:tube])
      expect(Saphyr::Library.first.tube.material_id).to be_present

    end

    it 'does not create any libraries if attributes are not valid' do
      factory = Saphyr::LibraryFactory.new({})
      expect(factory).not_to be_valid
      expect(factory.save).to be_falsey
      expect(Saphyr::Library.all.count).to eq(0)
      expect(Tube.all.count).to eq(0)
    end
  end

end
