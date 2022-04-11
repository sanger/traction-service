require "rails_helper"

# TODO:
# remove link to requestor model
# add relevant tests as per request
RSpec.describe Saphyr::Request, type: :model, saphyr: true do

  it_behaves_like 'requestor model'

  it 'can have many libraries' do
    request = create(:saphyr_request)
    request.libraries << create_list(:saphyr_library, 5)
    expect(request.libraries.count).to eq(5)
  end

end
