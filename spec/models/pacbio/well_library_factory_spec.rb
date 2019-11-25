# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::WellLibraryFactory, type: :model, pacbio: true do

  let(:well)                    { create(:pacbio_well) }
  let(:request_library_1)       { create(:pacbio_request_library_with_tag) }
  let(:request_library_2)       { create(:pacbio_request_library_with_tag) }
  let(:request_library_3)       { create(:pacbio_request_library_with_tag) }
  let(:request_library_4)       { create(:pacbio_request_library_with_tag) }
  let(:request_library_5)       { create(:pacbio_request_library_with_tag) }
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
  let(:library_ids_17)       { create_list(:pacbio_library, 17) }
  let(:library_ids_16)       { create_list(:pacbio_library, 16) }
  let(:request_library_no_tag)       { create(:pacbio_request_library) }
  let(:library_ids_one_tag)     { [{ type: 'libraries', id: request_library_no_tag.library.id }, { type: 'libraries', id: request_library_1.library.id }] }
  let(:library_ids_no_tag)     { [{ type: 'libraries', id: request_library_no_tag.library.id }, { type: 'libraries', id: request_library_no_tag.library.id }] }

  before(:each) do
    well.libraries << [request_library_1, request_library_2, request_library_3].collect(&:library)
  end

  context '#initialize' do
    it 'creates an object for each given library' do
      factory = Pacbio::WellLibraryFactory.new(well, library_ids)
      expect(factory.libraries.count).to eq(2)
    end

    it 'is valid if number of libraries in a well is less than or equal to 16' do
      factory = Pacbio::WellLibraryFactory.new(well, library_ids)
      expect(factory).to be_valid
    end

    it 'is not valid if number of libraries is greater than 16' do
      factory = Pacbio::WellLibraryFactory.new(well, library_ids_17)
      expect(factory).not_to be_valid
    end

    it 'is valid if there is only one library in the well' do
      factory = Pacbio::WellLibraryFactory.new(well, [library_ids[0]])
      expect(factory).to be_valid
    end

    it 'is valid if there is no more than 16 libraries in the well' do
      factory = Pacbio::WellLibraryFactory.new(well, library_ids_16)
      expect(factory).to be_valid
    end

    it 'is not valid if there is more than 16 libraries in the well' do
      factory = Pacbio::WellLibraryFactory.new(well, library_ids_17)
      expect(factory).to_not be_valid
      expect(factory.errors.messages[:libraries][0]).to eq 'There are more than 16 libraries in well ' + well.position
    end

    it 'is valid if none of the tags clash' do
      factory = Pacbio::WellLibraryFactory.new(well, library_ids)
      expect(factory).to be_valid
    end

    it 'produces an error if there are multiples libraries and any of the tags clash' do
      factory = Pacbio::WellLibraryFactory.new(well, library_ids_invalid)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages[0]).to eq 'Tags are not unique within the libraries for well ' + well.position 
    end

    it 'produces an error if there are multiples libraries and they do not have tags' do
      factory = Pacbio::WellLibraryFactory.new(well, library_ids_no_tag)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages[0]).to eq 'Tags are missing from the libraries'
    end

    it 'produces an error if there are multiples libraries and not all have tags' do
      factory = Pacbio::WellLibraryFactory.new(well, library_ids_one_tag)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages[0]).to eq 'Tags are missing from the libraries'
    end
  end

  context '#save' do
    it 'if valid adds the libraries to the well' do
      factory = Pacbio::WellLibraryFactory.new(well, library_ids)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(well.libraries.count).to eq(library_ids.length)
    end

    it 'if invalid wont save the libraries' do
      factory = Pacbio::WellLibraryFactory.new(well, library_ids_invalid)
      expect(factory).to_not be_valid
      expect(factory.save).to be_falsey
      expect(well.libraries.count).to eq(3)
    end

  end
end
