require "rails_helper"
require 'ostruct'

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

class ObjectC
  attr_reader :libraries

  def initialize(libraries = [])
    @libraries = libraries
  end

  def attr_e
    'another attribute'
  end
end

RSpec.describe Messages::Message, type: :model do

  let(:object_b)  { ObjectB.new('attr_d')}
  let(:object_a)  { ObjectA.new('attr_a', 'attr_b', object_b)}
  let(:params)    { {
                      key: 'a_table',
                      lims: 'a_lims',
                      fields: { 
                        instrument_name: { type: :string, value: 'saphyr' },
                        field_a: { type: :model, value: 'attr_a' }, 
                        field_b: { type: :model, value: 'attr_b' }, 
                        field_c: { type: :model, value: 'attr_c.attr_d' },
                        updated_at: { type: :constant, value: 'Time.current' }
                      }
                    }.with_indifferent_access
                  }

  let(:config) { OpenStruct.new(params) }

  let(:message) { Messages::Message.new(object: object_a, configuration: config ) }
  let(:timestamp) { Time.parse('Mon, 08 Apr 2019 09:15:11 UTC +00:00') }

  before(:each) do
    allow(Time).to receive(:current).and_return timestamp
  end

  it 'has some content' do
    expect(message.content).to eq(
      { config[:key] => {
        field_a: 'attr_a',
        field_b: 'attr_b',
        field_c: 'attr_d',
        updated_at: timestamp,
        instrument_name: 'saphyr'
      },
      lims: config[:lims],
      }.with_indifferent_access
    )
  end

  it 'has a payload' do
    expect(message.payload).to_not be_nil
  end

  context 'nested fields' do
    let(:children) { Array.new(5) { |o| o = ObjectB.new('attr_d')}}
    let(:object_c) { ObjectC.new(children)}
    let(:params)    { {
                      key: 'a_table',
                      lims: 'a_lims',
                      fields: { 
                        field_e: { type: :model, value: 'attr_e' },
                        samples: { 
                          type: :array, 
                          value: 'libraries',
                          children: {
                            field_d: { type: :model, value: 'attr_d' }
                          }
                        },
                      }
                    }.with_indifferent_access
                  }

  let(:config) { OpenStruct.new(params) }

  let(:message) { Messages::Message.new(object: object_c, configuration: config ) }

    it 'works' do
      expect(message.content).to eq(
        { config[:key] => {
          field_e: 'another attribute',
          samples: [
            { field_d: 'attr_d'},
            { field_d: 'attr_d'},
            { field_d: 'attr_d'},
            { field_d: 'attr_d'},
            { field_d: 'attr_d'}
          ]
        },
        lims: config[:lims],
        }.with_indifferent_access
    )
    end
  end

end
