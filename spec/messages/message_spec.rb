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
  def key
    'a_table'
  end

  def lims
    'a_lims'
  end

  def fields
    {
      field_a: 'attr_a',
      field_b: 'attr_b',
      field_c: 'attr_c.attr_d'
    }
  end
end

RSpec.describe Messages::Message, type: :model do

  let(:object_b) { ObjectB.new('attr_d')}
  let(:object_a) { ObjectA.new('attr_a', 'attr_b', object_b)}
  let(:configuration) { Configuration.new }

  let(:config) { { key: 'a_table', lims: 'a_lims', fields: { field_a: 'attr_a', field_b: 'attr_b', field_c: 'attr_c.attr_d' } } }

  let(:message) { Messages::Message.new(object: object_a, configuration: config ) }
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
      configuration.key => {
        field_a: 'attr_a',
        field_b: 'attr_b',
        field_c: 'attr_d',
        updated_at: timestamp
      },
      lims: configuration.lims
    )
  end

  it 'has a payload' do
    expect(message.payload).to_not be_nil
  end

end
