# TODO: autoloading order changed. This should be managed by configs instead:
# https://guides.rubyonrails.org/v7.0/autoloading_and_reloading_constants.html#autoloading-when-the-application-boots
require_relative 'restrooms'
require_relative 'bed_bug_reports'

module API
  module V1
    class Base < Grape::API
      use Rack::JSONP
      mount API::V1::BedBugReports
      mount API::V1::Restrooms  # Backward compatibility

      add_swagger_documentation base_path: '/api', api_version: 'v1', hide_documentation_path: true
    end
  end
end
