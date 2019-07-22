require 'rails_helper'

RSpec.describe Pacbio::Tag, type: :model, pacbio: true do

  it 'must have a sequence' do
    expect(build(:pacbio_tag, oligo: nil)).to_not be_valid
  end

  it 'must have a group id' do
    expect(build(:pacbio_tag, group_id: nil)).to_not be_valid
  end

end