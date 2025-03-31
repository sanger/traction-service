# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnotationType, type: :model do
  it 'must have a name' do
    expect(build(:annotation_type, name: nil)).not_to be_valid
  end

  it 'must have a unique name' do
    create(:annotation_type, name: 'Example Annotation Type')
    expect(build(:annotation_type, name: 'Example Annotation Type')).not_to be_valid
  end
end
