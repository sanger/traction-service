# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiKey do
  it 'is valid with factory defaults' do
    expect(build(:api_key)).to be_valid
  end

  describe '.issue!' do
    it 'issues a key and stores only a SHA-256 digest, not the plaintext' do
      api_application = create(:api_application)

      result = described_class.issue!(api_application: api_application)
      plaintext = result[:plaintext_key]

      expect(result[:api_key]).to be_persisted
      expect(result[:api_key].key_digest).to eq(Digest::SHA256.hexdigest(plaintext))
      expect(result[:api_key].key_digest).not_to eq(plaintext)
    end

    it 'issues non-expiring keys by default' do
      api_application = create(:api_application)

      result = described_class.issue!(api_application: api_application)

      expect(result[:api_key].expires_at).to be_nil
    end

    it 'allows issuing keys with explicit expiration' do
      api_application = create(:api_application)
      expires_at = 1.week.from_now

      result = described_class.issue!(api_application: api_application, expires_at: expires_at)

      expect(result[:api_key].expires_at).to eq(expires_at)
    end

    it 'allows issuing keys with explicit plaintext' do
      api_application = create(:api_application)
      plaintext_key = 'my-explicit-test-key'

      result = described_class.issue!(api_application: api_application, plaintext_key: plaintext_key)

      expect(result[:plaintext_key]).to eq(plaintext_key)
      expect(result[:api_key].key_digest).to eq(Digest::SHA256.hexdigest(plaintext_key))
    end
  end
end
