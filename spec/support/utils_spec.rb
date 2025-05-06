# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Utils do
  include described_class

  describe '#hash_to_struct' do
    it 'converts a hash into a Struct object' do
      hash = { name: 'John', age: 30 }
      struct = hash_to_struct(hash)

      expect(struct).to be_a(Struct)
      expect(struct.name).to eq('John')
      expect(struct.age).to eq(30)
    end

    it 'converts a hash with string keys into a Struct object' do
      hash = { 'name' => 'John', 'age' => 30 }
      struct = hash_to_struct(hash)
      expect(struct).to be_a(Struct)
      expect(struct.name).to eq('John')
      expect(struct.age).to eq(30)
    end

    it 'handles an empty hash gracefully' do
      hash = {}
      struct = hash_to_struct(hash)

      expect(struct).to be_a(Struct)
      expect(struct.members).to be_empty
    end
  end

  describe '#hash_to_deep_struct' do
    it 'converts a hash into a deep Struct object' do
      hash = { name: 'John', age: 30, address: { city: 'New York', zip: '10001' } }
      struct = hash_to_deep_struct(hash)

      expect(struct).to be_a(Struct)
      expect(struct.name).to eq('John')
      expect(struct.age).to eq(30)
      expect(struct.address).to be_a(Struct)
      expect(struct.address.city).to eq('New York')
      expect(struct.address.zip).to eq('10001')
    end

    it 'converts a hash with a second level of nesting into a deep Struct object' do
      hash = { name: 'John', age: 30, address: { city: 'New York', zip: { code: '10001' } } }
      struct = hash_to_deep_struct(hash)
      expect(struct).to be_a(Struct)
      expect(struct.name).to eq('John')
      expect(struct.age).to eq(30)
      expect(struct.address).to be_a(Struct)
      expect(struct.address.city).to eq('New York')
      expect(struct.address.zip).to be_a(Struct)
      expect(struct.address.zip.code).to eq('10001')
    end

    it 'handles an empty hash gracefully' do
      hash = {}
      struct = hash_to_deep_struct(hash)

      expect(struct).to be_a(Struct)
      expect(struct.members).to be_empty
    end
  end
end
