# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# only load Rake tasks if they haven't been loaded already
Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'RakeTasks' do
  describe 'printers:create' do
    it 'creates the printers' do
      expect { Rake::Task['printers:create'].invoke }.to change(Printer, :count).by(6).and output(
        <<~HEREDOC
          -> Printers succesfully updated
        HEREDOC
      ).to_stdout
    end
  end
end
