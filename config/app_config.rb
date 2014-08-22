require 'settingslogic'

class AppConfig < Settingslogic
  source File.expand_path('../application.yml', __FILE__)
end