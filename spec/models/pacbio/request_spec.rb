require 'rails_helper'

RSpec.describe Pacbio::Request, type: :model, pacbio: true do

  it_behaves_like 'requestor model'

end