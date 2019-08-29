require "rails_helper"

RSpec.describe 'RequestsController', type: :request, saphyr: true do

  let(:pipeline_name) { 'saphyr' }

  it_behaves_like 'requestor controller'

end
