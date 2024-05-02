# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# only load Rake tasks if they haven't been loaded already
Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'RakeTasks' do
  describe 'dummy_printers:create' do
    it 'creates the data types' do
      expect { Rake::Task['dummy_printers:create'].invoke }.to change(Printer, :count).by(4).and output(
        <<~HEREDOC
          -> Creating dummy printers
            -> Tube Printer
            -> 96-Well Plate Printer
            -> 384-Well Plate Printer
            -> Deactivated Printer
          -> Dummy printers created
        HEREDOC
      ).to_stdout
    end
  end
end
