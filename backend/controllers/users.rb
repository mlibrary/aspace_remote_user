require_relative '../../lib/trusted_login_endpoint'
include MLibrary

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
      do_login_trusted
    end
end
