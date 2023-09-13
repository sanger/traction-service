# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

RSpec.describe 'RakeTasks' do
  describe 'library_types:create' do
    it 'creates the library types' do
      expect { Rake::Task['library_types:create'].invoke }.to change(LibraryType, :count).by(15).and output(
        <<~HEREDOC
          -> Library types updated
        HEREDOC
      ).to_stdout
    end
  end
end
