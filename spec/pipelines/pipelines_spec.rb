require "rails_helper"

RSpec.describe Pipelines, type: :model do

  describe '#configuration' do

    let(:pipelines) { Rails.configuration.pipelines }

    it 'will have all of the pipelines' do
      expect(pipelines.keys.all? { |pipeline| Pipelines.configuration.respond_to?(pipeline)}).to be_truthy
    end

    it 'each pipeline will have a message' do
      expect(pipelines.keys.all? { |pipeline| Pipelines.configuration.send(pipeline).respond_to?(:message)}).to be_truthy
    end

    it '#delegation' do
      expect(pipelines.keys.all? { |pipeline| Pipelines.respond_to?(pipeline)}).to be_truthy
    end
  end

end