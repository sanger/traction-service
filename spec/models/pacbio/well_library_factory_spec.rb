# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::WellLibraryFactory, type: :model, pacbio: true do

  let(:well)                    { create(:pacbio_well) }
  let(:request_library_1)       { create(:pacbio_request_library)}
  let(:request_library_2)       { create(:pacbio_request_library)}
  let(:request_library_3)       { create(:pacbio_request_library)}
  let(:request_library_4)       { create(:pacbio_request_library)}
  let(:request_library_5)       { create(:pacbio_request_library)}
  let(:request_library_invalid) { create(:pacbio_request_library, tag: request_library_5.tag)}
  let(:library_ids)             { [
                                    {
                                      type: 'libraries', id: request_library_4.library.id
                                    },
                                    {
                                      type: 'libraries', id: request_library_5.library.id
                                    }
                                  ]
                                }
  let(:library_ids_invalid)     { library_ids.push({type: 'libraries', id: request_library_invalid.library.id}) }

  before(:each) do
    well.libraries << [request_library_1, request_library_2, request_library_3].collect(&:library)
  end

  context '#initialize' do

    it 'creates an object for each given library' do
      factory = Pacbio::WellLibraryFactory.new(well, library_ids)
      expect(factory.libraries.count).to eq(2)
    end

    it 'is valid if none of the tags clash' do
      factory = Pacbio::WellLibraryFactory.new(well, library_ids)
      expect(factory).to be_valid
    end

    it 'produces an error if any of the tags clash' do
      factory = Pacbio::WellLibraryFactory.new(well, library_ids_invalid)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end
  end

  context '#save' do
    it 'if valid adds the libraries to the well' do
      factory = Pacbio::WellLibraryFactory.new(well, library_ids)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(well.libraries.count).to eq(5)
    end

    it 'if invalid wont save the libraries' do
      factory = Pacbio::WellLibraryFactory.new(well, library_ids_invalid)
      expect(factory).to_not be_valid
      expect(factory.save).to be_falsey
      expect(well.libraries.count).to eq(3)
    end

  end
end
