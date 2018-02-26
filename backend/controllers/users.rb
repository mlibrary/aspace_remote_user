class ArchivesSpaceService < Sinatra::Base
  
  Endpoint.post('/users/:username/login/trusted')
    .description("Log in")
    .params(["username", Username, "Your username"],
            ["expiring", BooleanParam, "true if the created session should expire",
             :default => true])
    .permissions([])
    .returns([200, "Login accepted"],
             [403, "Login failed"]) \
  do
    if env['HTTP_X_FORWARDED_SERVER']
      # We are proxied, this is not a local connection. Kill it.
      json_response({:error => "Login failed"}, 403)
    else
      # local connection, trust it
      username = params[:username]
      user = User.find(:username => username)

      if user
        session = create_session_for(username, params[:expiring])
        json_user = User.to_jsonmodel(user)
        json_user.permissions = user.permissions
        json_response({:session => session.id, :user => json_user})
      else
        json_response({:error => "Login failed"}, 403)
      end
    end
  end

end
