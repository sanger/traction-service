# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiApplication do
  describe 'validations' do
    it 'is valid with factory defaults' do
      expect(build(:api_application)).to be_valid
    end

    it 'is invalid without a name' do
      expect(build(:api_application, name: nil)).not_to be_valid
    end

    it 'is invalid without a contact_name' do
      expect(build(:api_application, contact_name: nil)).not_to be_valid
    end
  end

  describe '.rotate_api_key!' do
    it 'issues API keys through rotation when no prior keys exist' do
      api_application = create(:api_application)

      result = api_application.rotate_api_key!

      expect(result[:api_key]).to be_persisted
      expect(result[:api_key].api_application).to eq(api_application)
      expect(result[:plaintext_key]).to be_a(String)
      expect(result[:plaintext_key].length).to eq(64) # 32-byte hex = 64 chars
    end

    it 'rotates API keys: active key moves to grace_period and a new active key is issued' do
      api_application = create(:api_application)
      current = api_application.rotate_api_key![:api_key]

      rotated = api_application.rotate_api_key!

      expect(current.reload).to be_grace_period
      expect(rotated[:api_key]).to be_active
      expect(rotated[:api_key].id).not_to eq(current.id)
    end

    it 'rotates API keys a second time: previous grace_period key moves to expired' do
      api_application = create(:api_application)
      original = api_application.rotate_api_key![:api_key]

      first_rotation = api_application.rotate_api_key![:api_key]
      api_application.rotate_api_key!

      expect(original.reload).to be_expired
      expect(first_rotation.reload).to be_grace_period
    end
  end
end
