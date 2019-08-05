# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::LibraryFactory, type: :model, pacbio: true do

  let(:tags)                { create_list(:tag, 3) }
  let(:requests)            { create_list(:pacbio_request, 3) }
  let(:library_attributes)  { [
                                attributes_for(:pacbio_library).merge(requests: [
                                  {id: requests.first.id, type: 'requests', tag: { id: tags.first.id, type: 'tags'}}, 
                                  {id: requests[1].id, type: 'requests', tag: { id: tags[1].id, type: 'tags'}}
                                ]),
                                attributes_for(:pacbio_library).merge(requests: [
                                  {id: requests[1].id, type: 'requests', tag: { id: tags[2].id, type: 'tags'}}
                                ]),
                                attributes_for(:pacbio_library).merge(requests: [
                                  {id: requests[2].id, type: 'requests', tag: { id: tags[2].id, type: 'tags'}}
                                ])
                              ]  
                            }


  context '#initialize' do
    it 'creates an object for each given request' do
      factory = Pacbio::LibraryFactory.new(library_attributes)
      expect(factory.libraries.count).to eq(3)
      expect(factory.libraries[0].tube).to be_present
      expect(factory.libraries[0].request_libraries.length).to eq(2)
    end

    it 'produces error messages if any of the libraries are not valid' do
      library_attributes << attributes_for(:pacbio_library).except(:volume)
      factory = Pacbio::LibraryFactory.new(library_attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

    it 'produces an error if any of the associated requests are invalid' do
      library_attributes << attributes_for(:pacbio_library).merge(requests: [{id: requests.first.id, type: 'requests'}])
      factory = Pacbio::LibraryFactory.new(library_attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end
  end

  context '#save' do
    it 'creates a library, a tube, and a request library' do
      factory = Pacbio::LibraryFactory.new(library_attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(factory.libraries.count).to eq(3)
      library = factory.libraries.first
      expect(library.tube).to be_present
      expect(library.requests.count).to eq(2)
    end

  end
end
