# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

RSpec.describe 'RakeTasks' do

  describe 'min_know_versions:create' do
    it 'creates the correct MinKnowVersion data' do
      expect { Rake::Task['min_know_versions:create'].invoke }.to change(Ont::MinKnowVersion, :count).and output("-> ONT MinKnow versions successfully created\n").to_stdout
    end
  end
end
