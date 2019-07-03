require "rails_helper"

RSpec.describe Saphyr::Request, type: :model, saphyr: true do

  it 'must have an external study id' do
    expect(build(:saphyr_request, external_study_id: nil)).to_not be_valid
  end

end
