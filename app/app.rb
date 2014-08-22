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
    auth = request.env["omniauth.auth"]

    user_exists = User.exists?( email: auth['info']['email'])
    pp user_exists

    # user = User.first_or_create({ :uid => auth["uid"]}, {
    #   :uid => auth["uid"],
    #   :nickname => auth["info"]["nickname"], 
    #   :name => auth["info"]["name"],
    #   :email => auth["info"]["email"],
    #   :created_at => Time.now })

    @authentication = Authentication.find_with_omniauth(auth)
    if @authentication.nil?
      if user_exists == true
        if signed_in?
          flash[:error] = "<p>The email connected to this app is already being used elsewhere in our system. Accounts can only be linked on a 1:1 basis.</p>"
          redirect to "/register"
        else
          flash[:error] = "<p>This email address already exists on another authentication. You need to login using the same method that you previously used.</p><p>Once you have successfully logged in you can connect your account to this social app if you choose.</p>"
          redirect to "/register"
        end

      else
        @authentication = Authentication.create_with_omniauth(auth)
      end
    end

    if signed_in?
      if @authentication.user == current_user
        flash[:success] = "You have linked this account"
        redirect to "/myaccount"
      else
        @authentication.user = current_user
        @authentication.save
        flash[:success] = "Account successfully authenticated"
        redirect to "/myaccount" 
      end
    else # no user is signed_in
      if @authentication.user.present?
        self.current_user = @authentication.user
        flash[:success] = "Signed in!"
        redirect to "/"
      else
        
        # puts "------------ @authentication.user "
        # pp @authentication.user
        # puts "------------ @authentication.user email "
        # pp auth['info']['email']

        if @authentication.provider == 'identity'
          u = User.find(@authentication.uid)
        else

          if user_exists == true
            flash[:error] = "This email address already exists on another account. Perhaps you logged in with a different method last time?"
            redirect to "/"
          else
            u = User.create_with_omniauth(auth)
          end
        end

        u.authentications << @authentication
        self.current_user = u
        redirect to "/"
      end
    end


    session[:user_id] = user.id
    redirect '/'

  end

  post '/auth/:name/callback' do
    auth = request.env['omniauth.auth']
    @authentication = Authentication.find_with_omniauth(auth)
    if @authentication.nil?
      @authentication = Authentication.create_with_omniauth(auth)
    end
    if signed_in?
      if @authentication.user == current_user
        redirect to "/", notice: "You have already linked this account"
      else
        @authentication.user = current_user
        @authentication.save
        redirect to "/", notice: "Account successfully authenticated"
      end
    else # no user is signed_in
      if @authentication.user.present?
        self.current_user = @authentication.user
        redirect to "/", notice: "Signed in!"
      else
        if @authentication.provider == 'identity'
          u = User.find(@authentication.uid)
        else
          u = User.create_with_omniauth(auth)
        end
        u.authentications << @authentication
        self.current_user = u
        redirect to "/"
      end
    end
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
