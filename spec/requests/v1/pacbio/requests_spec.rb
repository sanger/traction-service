require "rails_helper"

RSpec.describe 'RequestsController', type: :request, pacbio: true do

  let(:pipeline_name) { 'pacbio' }

  it_behaves_like 'requestor controller'

end
