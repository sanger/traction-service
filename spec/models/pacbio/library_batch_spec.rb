# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::LibraryBatch, :pacbio do
  it 'is valid with valid attributes' do
    library_batch = build(:pacbio_library_batch)
    expect(library_batch).to be_valid
  end

  it 'is not valid without libraries' do
    library_batch = build(:pacbio_library_batch, libraries: [])
    expect(library_batch).not_to be_valid
    expect(library_batch.errors[:libraries]).to include("can't be blank")
  end

  it 'nullifies associated libraries on destroy' do
    library_batch = create(:pacbio_library_batch)
    library = create(:pacbio_library, library_batch: library_batch)
    library_batch.destroy
    expect(library.reload.library_batch).to be_nil
  end
end
