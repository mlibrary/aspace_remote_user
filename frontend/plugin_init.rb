# REMOTE_USER based authentication

ArchivesSpace::Application::config.after_initialize do

  # models/user
  User.class_eval do
    # "login" method using environment rather than username/password to authenticate
    def self.env_login(context)
      username = context.env["HTTP_X_REMOTE_USER"]

      if (username.is_a?(String) and !username.empty?)
        uri = JSONModel(:user).uri_for("#{username}/login/trusted")
        response = JSONModel::HTTP.post_form(uri)

        if response.code == '200'
          ASUtils.json_parse(response.body)
        else
          nil
        end
      else
        nil
      end
    end
  end

  # controllers/application_controller
  ApplicationController.class_eval do
 
    before_filter :force_authentication
 
    # filter to execute env based login
    def force_authentication
      session[:session] and return # don't replace existing session

      backend_session = User.env_login(self)

      if backend_session
        User.establish_session(self, backend_session, backend_session["user"]["username"])
        load_repository_list
        # redirect_to :controller => :welcome, :action => :index
      end
      
    end
  end
    
  # controllers/session_controller
  SessionController.class_eval do
    def logout
      user_has_env_based_auth = (session[:user] == env["HTTP_X_REMOTE_USER"])
      reset_session
      if user_has_env_based_auth
        cookies.select {|k,v| /^cosign/.match k and cookies.delete(k)}
        redirect_to "https://webservices.itcs.umich.edu/cgi-bin/logout?http://www.lib.umich.edu/"
      else
        redirect_to :root
      end
    end
  end

end
