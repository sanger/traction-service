require 'rails_helper'

RSpec.describe Pacbio::Well, type: :model, pacbio: true do

  context 'movie time' do
    it 'must be present' do
      expect(build(:pacbio_well, movie_time: nil)).to_not be_valid
    end

    it 'must be within range' do
      expect(build(:pacbio_well, movie_time: 15)).to be_valid
      expect(build(:pacbio_well, movie_time: 31)).to_not be_valid
      expect(build(:pacbio_well, movie_time: 0)).to_not be_valid
    end

  end

  context 'insert size' do

    it 'must be present' do
      expect(build(:pacbio_well, insert_size: nil)).to_not be_valid
    end

    it 'must be within range' do
      expect(build(:pacbio_well, insert_size: 10)).to be_valid
      expect(build(:pacbio_well, insert_size: 5)).to_not be_valid
    end
  end

  it 'must have an on plate loading concentration' do
    expect(build(:pacbio_well, on_plate_loading_concentration: nil)).to_not be_valid
  end

  context 'position' do

    it 'must have a row' do
      expect(build(:pacbio_well, row: nil)).to_not be_valid
    end

    it 'must have a column' do
      expect(build(:pacbio_well, column: nil)).to_not be_valid
    end

    it 'can have a position' do
      expect(build(:pacbio_well, row: 'B', column: '01').position).to eq('B01')
    end
  end

  it 'must have to a plate' do
    expect(build(:pacbio_well, plate: nil)).to_not be_valid
  end

  it 'can have a comment' do
    expect(build(:pacbio_well).comment).to be_present
  end

end