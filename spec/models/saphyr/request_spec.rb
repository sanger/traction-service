require "rails_helper"

RSpec.describe Saphyr::Request, type: :model, saphyr: true do

  it_behaves_like 'requestor model'

end
