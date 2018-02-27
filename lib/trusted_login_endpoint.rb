require 'pry'
module MLibrary
  def do_login_trusted(user_class: User)
    if env['HTTP_X_FORWARDED_SERVER']
      # We are proxied, this is not a local connection. Kill it.
      json_response({:error => "Login failed"}, 403)
    else
      # local connection, trust it
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
    end
  end
end
