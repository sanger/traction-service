# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuperStruct do
  describe '#initialize' do
    it 'creates a struct from a hash' do
      hash = { name: 'John', age: 30 }
      struct = described_class.new(hash)

      expect(struct.name).to eq('John')
      expect(struct.age).to eq(30)
    end

    it 'creates a deep struct when deep: true is passed' do
      hash = { person: { name: 'John', age: 30 }, city: 'New York' }
      struct = described_class.new(hash, deep: true)

      expect(struct.person.name).to eq('John')
      expect(struct.person.age).to eq(30)
      expect(struct.city).to eq('New York')
    end
  end

  describe '#==' do
    it 'returns true for two SuperStructs with the same content' do
      hash1 = { name: 'John', age: 30 }
      hash2 = { name: 'John', age: 30 }
      struct1 = described_class.new(hash1)
      struct2 = described_class.new(hash2)

      expect(struct1).to eq(struct2)
    end

    it 'returns false for two SuperStructs with different content' do
      hash1 = { name: 'John', age: 30 }
      hash2 = { name: 'Jane', age: 25 }
      struct1 = described_class.new(hash1)
      struct2 = described_class.new(hash2)

      expect(struct1).not_to eq(struct2)
    end
  end

  describe '#method_missing' do
    it 'delegates method calls to the underlying struct' do
      hash = { name: 'John', age: 30 }
      struct = described_class.new(hash)

      expect(struct.name).to eq('John')
      expect(struct.age).to eq(30)
    end

    it 'raises NoMethodError for undefined methods' do
      hash = { name: 'John', age: 30 }
      struct = described_class.new(hash)

      expect { struct.undefined_method }.to raise_error(NoMethodError)
    end
  end

  describe '#respond_to_missing?' do
    it 'returns true for methods defined in the underlying struct' do
      hash = { name: 'John', age: 30 }
      struct = described_class.new(hash)

      expect(struct.respond_to?(:name)).to be true
      expect(struct.respond_to?(:age)).to be true
    end

    it 'returns false for methods not defined in the underlying struct' do
      hash = { name: 'John', age: 30 }
      struct = described_class.new(hash)

      expect(struct.respond_to?(:undefined_method)).to be false
    end
  end

  describe 'deep struct behavior' do
    it 'handles nested hashes correctly' do
      hash = { person: { name: 'John', age: 30 }, city: 'New York' }
      struct = described_class.new(hash, deep: true)

      expect(struct.person.name).to eq('John')
      expect(struct.person.age).to eq(30)
      expect(struct.city).to eq('New York')
    end
  end
end
