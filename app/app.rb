# Application routes listed here
# Author:: Chandan Kumar (http://chandankumar.com)
class AdminApp < Sinatra::Base
  set(:auth) do |*roles|
    condition do
      unless signed_in? && roles.any? {|role| current_user.role.to_sym == role }
        redirect "/login", 303
      end
    end
  end

  get "/" do
    erb :index
  end

  get "/about" do
    erb :about
  end

  get '/register' do
    if signed_in?
      redirect to "/myaccount"
    else
      erb :register
    end
  end

  post "/register" do
    @identity = env['omniauth.identity']
    erb :register
  end

  get "/login" do
    erb :login
  end

  get '/auth/:name/callback' do
    do_login
  end

  post '/auth/:name/callback' do
    do_login
  end

  get '/auth/failure' do
    @error = "Invalid Credentials. Try again"
    erb :login
  end

  get "/logout" do
    session[:user_id] = nil
    session.clear
    redirect to "/"
  end

  get "/protected", :auth => [:user, :admin] do
    erb :protected
  end

  get "/myaccount", :auth => [:user, :admin] do
    @authentications = current_user.authentications
    erb :myaccount
  end

  get "/manage", :auth => [:admin] do
    erb :manage
  end
end
