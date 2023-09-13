# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

RSpec.describe 'RakeTasks' do
  describe 'ont_instruments:create' do
    it 'creates the correct instrument data' do
      Rake::Task['ont_instruments:create'].reenable
      expect { Rake::Task['ont_instruments:create'].invoke }.to change(Ont::Instrument, :count).and output(
        <<~HEREDOC
          -> ONT Instruments successfully created
        HEREDOC
      ).to_stdout
    end
  end
end
