# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TagTaggable do
  it 'is not valid without a tag' do
    expect(build(:tag_taggable, tag: nil)).not_to be_valid
  end

  it 'is not valid without a taggable' do
    expect(build(:tag_taggable, taggable: nil)).not_to be_valid
  end
end
