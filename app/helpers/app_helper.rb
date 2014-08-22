class AdminApp < Sinatra::Base
  helpers do
    def logged_in?
      !session[:user_id].nil?
    end
  end

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def signed_in?
    !!current_user
  end

  def current_user=(user)
    @current_user = user
    session[:user_id] = user.nil? ? user : user.id
  end


  def do_login
    auth = request.env["omniauth.auth"]

    user_exists = User.exists?( email: auth['info']['email'])
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
    else 
      if @authentication.user.present?
        self.current_user = @authentication.user
        flash[:success] = "Signed in!"
        redirect to "/"
      else
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


end