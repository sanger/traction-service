require 'rails_helper'

RSpec.describe Pacbio::Tag, type: :model, pacbio: true do

  it 'must have a sequence' do
    expect(build(:pacbio_tag, oligo: nil)).to_not be_valid
  end

end