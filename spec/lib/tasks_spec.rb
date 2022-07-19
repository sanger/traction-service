# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

RSpec.describe 'RakeTasks' do
  describe 'library_types:create' do
    it 'creates the library types' do
      expect { Rake::Task['library_types:create'].invoke }.to(
        change(LibraryType, :count).by(13) &&
        output("-> Library types updated\n").to_stdout
      )
    end
  end

  describe 'data_types:create' do
    it 'creates the data types' do
      expect { Rake::Task['data_types:create'].invoke }.to(
        change(DataType, :count).by(2) &&
        output("-> Data types updated\n").to_stdout
      )
    end
  end
end
