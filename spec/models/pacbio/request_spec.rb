require 'rails_helper'

RSpec.describe Pacbio::Request, type: :model, pacbio: true do

  it_behaves_like 'requestor model'

  context 'libraries' do
    it 'can have one or more' do
      request = create(:pacbio_request)
      create_list(:pacbio_library_with_tag, 5, request: request)
      expect(request.libraries.count).to eq(5)
    end
  end

end
