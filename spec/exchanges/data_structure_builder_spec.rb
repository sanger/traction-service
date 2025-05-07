# frozen_string_literal: true

require 'rails_helper'

class MockDataStructureBuilder
  include DataStructureBuilder

  def some_attribute
    'mocked value'
  end

  def nested_object
    {
      name: 'John Doe',
      age: 30
    }
  end
end

RSpec.describe DataStructureBuilder do
  describe '#data_structure' do
    let(:object) { double('Object') }
    let(:configuration) do
      SuperStruct.new(
        { fields: {
          name: { type: :string, value: 'John Doe' },
          age: { type: :model, value: 'person.age' },
          birthdate: { type: :constant, value: 'DateTime.now' },
          hobbies: { type: :array, value: 'hobbies', children: { name: { type: :string, value: 'Soccer' } } }
        } }
      )
    end
    let(:builder) { MockDataStructureBuilder.new(object:, configuration:) }

    before do
      allow(object).to receive_message_chain(:person, :age).and_return(30)
      allow(DateTime).to receive(:now).and_return(Date.new(2023, 4, 1))
      allow(object).to receive(:hobbies).and_return([{ name: 'Soccer' }])
    end

    it 'builds the correct data structure' do
      expected_structure = {
        name: 'John Doe',
        age: 30,
        birthdate: Date.new(2023, 4, 1),
        hobbies: [{ name: 'Soccer' }]
      }

      expect(builder.data_structure).to eq(expected_structure)
    end
  end

  describe '#instance_value' do
    let(:object) { double('Object') }
    let(:parent) { double('Parent') }
    let(:builder) { MockDataStructureBuilder.new }

    context 'when field type is :string' do
      it 'returns the value' do
        field = { type: :string, value: 'Test String' }
        expect(builder.send(:instance_value, object, field, parent)).to eq('Test String')
      end
    end

    context 'when field type is :model' do
      it 'evaluates the field on the object' do
        field = { type: :model, value: 'method.chain' }
        allow(object).to receive_message_chain(:method, :chain).and_return('result')
        expect(builder.send(:instance_value, object, field, parent)).to eq('result')
      end

      it 'evaluates the field on the object with &. accessor' do
        field = { type: :model, value: 'method&.chain' }
        allow(object).to receive_message_chain(:method, :chain).and_return('result')
        expect(builder.send(:instance_value, object, field, parent)).to eq('result')
      end
    end

    context 'when field type is :parent_model' do
      it 'evaluates the field on the parent object' do
        field = { type: :parent_model, value: 'parent_method' }
        allow(parent).to receive(:parent_method).and_return('parent result')
        expect(builder.send(:instance_value, object, field, parent)).to eq('parent result')
      end
    end

    context 'when field type is :array' do
      let(:child_builder) { double('ChildBuilder') }

      before do
        allow(builder).to receive(:build_children).and_return([{ name: 'Child 1' }, { name: 'Child 2' }])
      end

      it 'builds an array of structured data' do
        field = { type: :array, value: 'children', children: { name: { type: :string, value: 'child.name' } } }
        allow(object).to receive(:children).and_return([child_builder, child_builder])
        expected_result = [{ name: 'Child 1' }, { name: 'Child 2' }]

        expect(builder.send(:instance_value, object, field, parent)).to eq(expected_result)
      end
    end

    context 'when field type is :self' do
      let(:builder_object) { MockDataStructureBuilder.new }

      it 'returns the attribute' do
        field = { type: :self, value: 'some_attribute' }
        expect(builder_object.send(:instance_value, object, field, parent)).to eq('mocked value')
      end

      it 'evaluates the field on the object with &. accessor' do
        field = { type: :self, value: 'nested_object&.name' }
        expect(builder_object.send(:instance_value, object, field, parent)).to eq('John Doe')
      end
    end
  end
end
