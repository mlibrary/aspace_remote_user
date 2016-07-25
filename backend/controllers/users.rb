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

  Endpoint.post('/remote_user/users')
    .description("Create a remote_user user")
    .params(["groups", [String], "Array of groups URIs to assign the user to", :optional => true],
            ["user", JSONModel(:user), "The record to create", :body => true])
    .permissions([])
    .returns([200, :created],
             [400, :error]) \
  do
    if env['HTTP_X_FORWARDED_SERVER']
      # We are proxied, this is not a local connection. Kill it.
      json_response({:error => "Denied"}, 403)
    else
      params[:user].username = Username.value(params[:user].username)

      user = User.create_from_json(params[:user], :source => "local")

      groups = Array(params[:groups]).map {|uri|
        group_ref = JSONModel.parse_reference(uri)
        repo_id = JSONModel.parse_reference(group_ref[:repository])[:id]

        RequestContext.open(:repo_id => repo_id) do
          if current_user.can?(:manage_repository)
            Group.get_or_die(group_ref[:id])
          else
            raise AccessDeniedException.new
          end
        end
      }

      user.add_to_groups(groups)

      created_response(user, params[:user])
    end
  end

end
