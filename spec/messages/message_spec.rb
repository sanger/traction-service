# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Messages::Message do
  let(:run) { create(:run_with_chip) }
  let(:msg) {  Messages::Message.new(run) }

  describe 'init' do
    it 'can be initialized with a run' do
      expect(msg.run).to eq run
    end
  end

  describe '#generate_json' do
    
    it 'creates the json' do
      json = JSON.parse(msg.generate_json)
      expect(json['id']).to eq run.id
      expect(json['name']).to eq run.name
      expect(json['chip_barcode']).to eq run.chip.barcode
    end
  end
end
