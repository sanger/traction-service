# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::RunFactory do
  it 'builds a new run' do
    run_factory = described_class.new
    expect(run_factory.run).to be_present
  end
end
