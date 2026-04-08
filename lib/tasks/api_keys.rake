# frozen_string_literal: true

namespace :api_keys do
  desc 'Rotate API key for a single app: rake "api_keys:rotate[api_application_name,expires_at]"'
  task :rotate, %i[api_application_name expires_at] => :environment do |_task, args|
    api_application_name = args[:api_application_name]
    raise ArgumentError, 'api_application_name is required' if api_application_name.blank?

    api_application = ApiApplication.find_by(name: api_application_name)
    unless api_application
      raise ActiveRecord::RecordNotFound, "ApiApplication '#{api_application_name}' not found"
    end

    expires_at = nil
    if args[:expires_at].present?
      expires_at = Time.zone.parse(args[:expires_at])
      if expires_at.nil?
        raise ArgumentError, "Invalid expires_at '#{args[:expires_at]}'. Use an ISO-like datetime."
      end
    end

    result = api_application.rotate_api_key!(expires_at: expires_at)

    puts "Rotated API key for app #{api_application.id} (#{api_application.name})"
    puts "  New key: #{result[:plaintext_key]}"
    puts "  Expires: #{result[:api_key].expires_at || 'default policy'}"
    puts 'Rotation complete.'
  end
end
