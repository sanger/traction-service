require 'rails_helper'

RSpec.describe Pacbio::Request, type: :model, pacbio: true do

  it_behaves_like 'requestor model'

  context 'libraries' do
    it 'can have one or more' do
      request = create(:pacbio_request)
      (1..5).each do |i|
        create(:pacbio_request_library, request: request, library: create(:pacbio_library), tag: create(:tag))
      end
      expect(request.libraries.count).to eq(5)
    end
  end

end