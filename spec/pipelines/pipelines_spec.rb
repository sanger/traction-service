# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pipelines, type: :model do
  describe '#configuration' do
    let(:pipelines) { Rails.configuration.pipelines }

    it 'will have all of the pipelines' do
      expect(pipelines.keys).to be_all do |pipeline|
        described_class.configuration.respond_to?(pipeline)
      end
    end

    it 'each pipeline will have a message' do
      expect(pipelines.keys).to be_all do |pipeline|
        described_class.configuration.send(pipeline).respond_to?(:message)
      end
    end

    it '#delegation' do
      expect(pipelines.keys).to be_all { |pipeline| described_class.respond_to?(pipeline) }
    end
  end
end
