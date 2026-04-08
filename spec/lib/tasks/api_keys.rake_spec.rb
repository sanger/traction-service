# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# only load Rake tasks if they haven't been loaded already
Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'RakeTasks' do
  describe 'api_keys:rotate' do
    before do
      Rake::Task['api_keys:rotate'].reenable
    end

    it 'rotates an API key for a single application by name' do
      api_application = create(:api_application)

      expect { Rake::Task['api_keys:rotate'].invoke(api_application.name) }
        .to change(ApiKey, :count).by(1)
        .and output(/Rotation complete\./).to_stdout
    end

    it 'requires api_application_name argument' do
      expect { Rake::Task['api_keys:rotate'].invoke }
        .to raise_error(ArgumentError, 'api_application_name is required')
    end

    it 'raises when application name does not exist' do
      expect { Rake::Task['api_keys:rotate'].invoke('missing-app') }
        .to raise_error(ActiveRecord::RecordNotFound, "ApiApplication 'missing-app' not found")
    end

    it 'raises for invalid expires_at format' do
      api_application = create(:api_application)

      expect { Rake::Task['api_keys:rotate'].invoke(api_application.name, 'not-a-date') }
        .to raise_error(ArgumentError, /Invalid expires_at/)
    end
  end
end
