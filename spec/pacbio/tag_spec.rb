require 'rails_helper'

RSpec.describe Pacbio::Tag, type: :model, pacbio: true do

  it 'must have a sequence' do
    expect(build(:pacbio_tag, oligo: nil)).to_not be_valid
  end

  it 'can have a library' do
    library = create(:pacbio_library)
    tag = create(:pacbio_tag, library: library)
    expect(tag.library).to eq(library)
  end
  
end