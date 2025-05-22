# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# only load Rake tasks if they haven't been loaded already
Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'RakeTasks' do
  describe 'annotation_types:create' do
    it 'creates the annotation types' do
      expect { Rake::Task['annotation_types:create'].invoke }.to change(AnnotationType, :count).by(4).and output(
        <<~HEREDOC
          -> Annotation types updated
        HEREDOC
      ).to_stdout
    end
  end
end
