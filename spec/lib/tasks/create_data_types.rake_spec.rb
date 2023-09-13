# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

RSpec.describe 'RakeTasks' do
  describe 'data_types:create' do
    it 'creates the data types' do
      expect { Rake::Task['data_types:create'].invoke }.to change(DataType, :count).by(2).and output(
        <<~HEREDOC
          -> Data types updated
        HEREDOC
      ).to_stdout
    end
  end
end
