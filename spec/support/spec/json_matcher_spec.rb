# frozen_string_literal: true

require 'rails_helper'

require './spec/support/json_matcher'

RSpec.describe 'JsonMatcher' do
  describe '#check_key' do
    it 'can perform checks' do
      expect(check_key({ 'a' => 1 }, 'a')).to be_truthy
      expect(check_key({ 'a' => 1 }, 'b')).to be_falsy
    end
  end

  describe '#check_regexp' do
    it 'can perform checks' do
      expect(check_regexp({ 'a' => '1' }, { 'a' => /\d/ }, 'a')).to be_truthy
      expect(check_regexp({ 'a' => '1' }, { 'b' => /\d/ }, 'a')).to be_nil
      expect(check_regexp({ 'a' => 'm' }, { 'a' => /\d/ }, 'a')).to be_falsy
    end
  end

  describe '#check_subtree' do
    it 'can perform checks' do
      expect(check_subtree({ 'a' => { 'b' => '1' } }, { 'a' => { 'b' => '1' } }, 'a')).to be_truthy
      expect(check_subtree({ 'a' => { 'b' => '1' } }, { 'a' => { 'b' => '2' } }, 'a')).to be_falsy
    end
  end

  describe '#check_array' do
    it 'can perform checks' do
      expect(check_array({ 'a' => [1] }, { 'a' => [1] }, 'a')).to be_truthy
      expect(check_array({ 'a' => [{ 'b' => '1' }] }, { 'a' => [{ 'b' => '1' }] }, 'a')).to be_truthy
      expect(check_array({ 'a' => [{ 'b' => '1' }] }, { 'a' => [{ 'b' => '2' }] }, 'a')).to be_falsy
    end
  end

  describe '#check_value' do
    it 'can perform checks' do
      expect(check_value({ 'a' => 1 }, { 'a' => 1 }, 'a')).to be_truthy
      expect(check_value({ 'a' => 1 }, { 'a' => 2 }, 'a')).to be_falsy
    end
  end

  describe '#check_objects' do
    it 'can perform checks' do
      expect(check_objects({ 'a' => 1 }, { 'a' => 1 })).to be_truthy
      expect(check_objects({ 'a' => 1 }, { 'a' => 2 })).to be_falsy
    end
  end

  describe '#match_json' do
    it 'can perform checks' do
      expect(match_json('{"a": 1}', { 'a' => 1 })).to be_truthy
      expect(match_json('{"a": 1}', { 'a' => 2 })).to be_falsy
    end
  end
end
