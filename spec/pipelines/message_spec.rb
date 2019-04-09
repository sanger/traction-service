require "rails_helper"

class ObjectB
  attr_reader :attr_d

  def initialize(attr_d)
    @attr_d = attr_d
  end
end

class ObjectA
  attr_reader :attr_a, :attr_b, :attr_c

  def initialize(attr_a, attr_b, attr_c)
    @attr_a = attr_a
    @attr_b = attr_b
    @attr_c = attr_c
  end
end

class Configuration
  def table
    'a_table'
  end

  def id_lims
    'an_id'
  end

  def fields
    {
      field_a: 'attr_a',
      field_b: 'attr_b',
      field_c: 'attr_c.attr_d'
    }
  end
end

RSpec.describe Pipelines::Message, type: :model do

  let(:object_b) { ObjectB.new('attr_d')}
  let(:object_a) { ObjectA.new('attr_a', 'attr_b', object_b)}
  let(:configuration) { Configuration.new }
  let(:message) { Pipelines::Message.new(object: object_a, configuration: configuration ) }
  let(:timestamp) { Time.parse('Mon, 08 Apr 2019 09:15:11 UTC +00:00') }

  before(:each) do
    allow(Time).to receive(:current).and_return timestamp
  end

  it 'works' do
    expect(true).to be_truthy
  end

  it 'has a timestamp' do
    expect(message.timestamp).to eq(timestamp)
  end

  it 'has some content' do
    expect(message.content).to eq(
      field_a: 'attr_a', 
      field_b: 'attr_b', 
      field_c: 'attr_d',
      updated_at: timestamp,
      id_lims: configuration.id_lims
    )
  end



end