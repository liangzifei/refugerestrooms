# Grape API classes use the API namespace and are loaded via require_relative in config/routes.rb.
# Keep Zeitwerk from expecting Api::Base during eager loading in production.
Rails.autoloaders.main.ignore(
  Rails.root.join("app/controllers/api/base.rb"),
  Rails.root.join("app/controllers/api/v1")
)
