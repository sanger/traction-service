# frozen_string_literal: true

require 'rails_helper'

class ChildrenList
  include ActiveModel::Validations

  attr_reader :number_of_children, :children

  def initialize(number_of_children)
    @number_of_children = number_of_children
    @children ||= (1..number_of_children).map do |_i|
      ChildItem.new
    end
  end

  class ChildItem
    include ActiveModel::Model

    def mark_for_destruction
      @marked_for_destruction = true
    end

    def marked_for_destruction?
      @marked_for_destruction
    end
  end
end

RSpec.describe LimitsValidator do
  let(:options) { { minimum: 2, maximum: 5, attribute: :children, exclude_marked_for_destruction: true } }

  it 'is valid when the number of children is within the limits' do
    children_list = ChildrenList.new(3)
    validator = described_class.new(options)
    validator.validate(children_list)
    expect(children_list.errors).to be_empty

    children_list = ChildrenList.new(5)
    validator = described_class.new(options)
    validator.validate(children_list)
    expect(children_list.errors).to be_empty
  end

  it 'validates the minimum number of children' do
    children_list = ChildrenList.new(0)
    validator = described_class.new(options)
    validator.validate(children_list)

    expect(children_list.errors[:children]).to include('must have at least 2 children')

    children_list = ChildrenList.new(1)
    validator = described_class.new(options)
    validator.validate(children_list)
    expect(children_list.errors[:children]).to include('must have at least 2 children')
  end

  it 'validates the maximum number of children' do
    children_list = ChildrenList.new(6)
    validator = described_class.new(options)
    validator.validate(children_list)
    expect(children_list.errors[:children]).to include('must have at most 5 children')

    children_list = ChildrenList.new(10)
    validator = described_class.new(options)
    validator.validate(children_list)
    expect(children_list.errors[:children]).to include('must have at most 5 children')
  end

  it 'excludes records marked for destruction' do
    children_list = ChildrenList.new(6)
    children_list.children.first.mark_for_destruction

    validator = described_class.new(options)
    validator.validate(children_list)
    expect(children_list.errors).to be_empty
  end
end
