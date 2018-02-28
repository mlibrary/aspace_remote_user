module MLibrary
  def do_login_trusted(user_class: User)
    if !env['HTTP_X_FORWARDED_SERVER'] && params[:password]==AppConfig[:mlibrary_remote_user_password]
      # everything looks okay, trust the client and make user session
      username = params[:username]
      user = user_class.find(:username => username)

      if user
        session = create_session_for(username, params[:expiring])
        json_user = user_class.to_jsonmodel(user)
        json_user.permissions = user.permissions
        json_response({:session => session.id, :user => json_user})
      else
        json_response({:error => "Login failed"}, 403)
      end
    else
      # Request is either proxied or lacking a correct password
      json_response({:error => "Login failed"}, 403)
    end
  end
end
