# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiKey do
  it 'is valid with factory defaults' do
    expect(build(:api_key)).to be_valid
  end

  it 'issues a key and stores only a SHA-256 digest, not the plaintext' do
    api_application = create(:api_application)

    result = described_class.issue!(api_application: api_application)
    plaintext = result[:plaintext_key]

    expect(result[:api_key]).to be_persisted
    expect(result[:api_key].key_digest).to eq(Digest::SHA256.hexdigest(plaintext))
    expect(result[:api_key].key_digest).not_to eq(plaintext)
  end
end
