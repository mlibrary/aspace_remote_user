class ArchivesSpaceService < Sinatra::Base
  
  # Should this look more like become user?
  # add trusted IP, distrust proxy?
  # disallow for system users
  Endpoint.post('/users/:username/login/trusted')
    .description("Log in")
    .params(["username", Username, "Your username"],
            ["expiring", BooleanParam, "true if the created session should expire",
             :default => true])
    .permissions([])
    .returns([200, "Login accepted"],
             [403, "Login failed"]) \
  do
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

  Endpoint.post('/remote_user/users')
    .description("Create a local user")
    .params(
            ["groups", [String], "Array of groups URIs to assign the user to", :optional => true],
            ["user", JSONModel(:user), "The record to create", :body => true])
    .permissions([])
    .returns([200, :created],
             [400, :error]) \
  do
    check_admin_access
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
