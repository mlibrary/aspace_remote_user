# Sample config for testing. Add 'aspace_remote_user' to your own list of plugins.
AppConfig[:plugins] = ['local',  'lcnaf', 'aspace_remote_user']

# This is an arbitrary value. Use somethig random.
AppConfig[:mlibrary_remote_user_password] = "YOU_MUST_CHANGE_THIS"

# Name of env var where your web stack populates the user name
AppConfig[:mlibrary_remote_user_env_var] = "HTTP_X_REMOTE_USER"

# Name of env var set by your web stack when serving proxied requests. Used to
# prohibit outside (and thus proxied) requests to the API from using our private
# API endpoint.
AppConfig[:mlibrary_remote_user_backend_prohibited_env_var] = "HTTP_X_FORWARDED_SERVER"

# Where to redirect users when they are logging out
AppConfig[:mlibrary_remote_user_cosign_logout_url] = "https://webservices.itcs.umich.edu/cgi-bin/logout?http://www.lib.umich.edu/"

