require 'rails_helper'

RSpec.describe QcResultsDecision, type: :model do
  context "testing associations" do
    it { should belong_to(:qc_result) }
    it { should belong_to(:qc_decision) }
  end
end
