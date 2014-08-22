require 'haml'
require 'omniauth'
require 'omniauth-facebook'
require 'omniauth-github'
require 'omniauth-twitter'
require 'omniauth-google-oauth2'
require 'pp'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'sqlite3'
require 'yaml'

Dir["./models/*.rb", "./initializers/*.rb", "./lib/*.rb", "./app/*.rb", "./app/helpers/*.rb"].each {|file| require file }
require "./config/app_config"


class AdminApp < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  register Sinatra::Flash
  
  configure :production, :development do
    set :logging, Logger::DEBUG
  end

  set :database, AppConfig.database_path
  use Rack::Session::Cookie, secret: AppConfig.session_secret

  use OmniAuth::Builder do
    provider :identity, fields: [:email, :name], model: User, on_failed_registration: lambda { |env|
      status, headers, body = call env.merge("PATH_INFO" => '/register')
    }

    AppConfig.providers.each do |provider|
      provider provider.strategy_name, provider.id, provider.secret
    end

    OmniAuth.config.on_failure = Proc.new { |env|
      OmniAuth::FailureEndpoint.new(env).redirect_to_failure
    }
  end

end
