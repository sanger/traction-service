# frozen_string_literal: true

require 'rails_helper'

class MyClass
  include ActiveModel::Model

  attr_accessor :attr_a, :attr_b, :attr_c, :attr_d, :smrt_link_version
end

RSpec.describe RequiredAttributesValidator do
  it 'is valid when all required attributes are present' do
    my_class = MyClass.new(attr_a: 'a', attr_b: 'b', attr_c: 'c', attr_d: 'd')
    validator = described_class.new(required_attributes: %i[attr_b attr_c])
    validator.validate(my_class)
    expect(my_class.errors).to be_empty
  end

  it 'is invalid when a required attribute is missing' do
    required_attributes = %i[attr_b attr_c]
    attributes_hash = { attr_a: 'a', attr_b: 'b', attr_c: 'c', attr_d: 'd' }

    validator = described_class.new(required_attributes:)

    required_attributes.each do |required_attribute|
      my_class = MyClass.new(attributes_hash.except(required_attribute))
      validator.validate(my_class)
      expect(my_class.errors[required_attribute]).to include("can't be blank")
    end
  end

  it 'is valid when all required attributes are present for a given version' do
    smrt_link_version = { name: '1' }
    def smrt_link_version.name
      1
    end
    my_class = MyClass.new(attr_a: 'a', attr_b: 'b', attr_c: 'c', attr_d: 'd', smrt_link_version:)
    validator = described_class.new(required_attributes: %i[attr_b attr_c], versions: ['1'])
    validator.validate(my_class)
    expect(my_class.errors).to be_empty
  end

  it 'is invalid when all required attributes are missing for a given version' do
    smrt_link_version = { name: '1' }
    def smrt_link_version.name
      '1'
    end
    required_attributes = %i[attr_b attr_c]
    attributes_hash = { attr_a: 'a', attr_b: 'b', attr_c: 'c', attr_d: 'd' }

    validator = described_class.new(required_attributes:, versions: ['1'])

    required_attributes.each do |required_attribute|
      attributes = attributes_hash.except(required_attribute).merge(smrt_link_version:)
      my_class = MyClass.new(attributes)
      validator.validate(my_class)
      expect(my_class.errors[required_attribute]).to include("can't be blank")
    end
  end

  it 'is valid when all required attributes are missing for a version other than given version' do
    smrt_link_version = { name: '1' }
    def smrt_link_version.name
      '1'
    end
    required_attributes = %i[attr_b attr_c]
    attributes_hash = { attr_a: 'a', attr_b: 'b', attr_c: 'c', attr_d: 'd' }

    validator = described_class.new(required_attributes:, versions: ['2'])

    required_attributes.each do |required_attribute|
      attributes = attributes_hash.except(required_attribute).merge(smrt_link_version:)
      my_class = MyClass.new(attributes)
      validator.validate(my_class)
      expect(my_class.errors).to be_empty
    end
  end
end
