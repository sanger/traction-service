# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Annotation do
  describe 'comments' do
    it 'is invalid without a comment' do
      expect(build(:annotation, comment: nil)).not_to be_valid
    end

    it 'is invalid with a comment longer than 500 characters' do
      long_comment = 'a' * 501
      expect(build(:annotation, comment: long_comment)).not_to be_valid
    end

    it 'is valid with a comment of 500 characters' do
      long_comment = 'a' * 500
      expect(build(:annotation, comment: long_comment)).to be_valid
    end

    it 'comment must be greater than 0 characters' do
      expect(build(:annotation, comment: '')).not_to be_valid
    end
  end

  describe 'user' do
    it 'is invalid without a user' do
      expect(build(:annotation, user: nil)).not_to be_valid
    end

    it 'user must be greater than 0 characters' do
      expect(build(:annotation, user: '')).not_to be_valid
    end
  end

  it 'is invalid without an annotation_type' do
    expect(build(:annotation, annotation_type: nil)).not_to be_valid
  end

  it 'is invalid without an annotatable' do
    expect(build(:annotation, annotatable: nil)).not_to be_valid
  end
end
