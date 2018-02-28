# aspace\_remote\_user
Allow login via environment variable for ArchivesSpace.

## Overview
ArchivesSpace normally handles all auth on the backend, the frontend simply passes the user password to the backend to handle this. This obviously won't work for web hosting stacks that use frontend auth middleware such as CoSign. This plugin allows ASpace to authenticate in such cases using an environment variable (set by your web hosting stack) containing the user name.

## Usage
First:

    cd $YOUR_ASPACE_INSTALL/plugins
    git clone https://github.com/mlibrary/aspace_remote_user.git

Then review the content of `sample_config.rb` and copy its content as appropriate to your `config.rb`.

Users may be created in the usual manner. A password is still required to create the user but will no longer be used for frontend requests. If the user will not be using the API you may simply set the password to a random string.

## Implimentation details
We create a new backend API endpoint that does not require a user password, but instead a configured app level password, for creating a new user session. The frontend automatically calls this endpoint if it finds the expected environment variable. If the user name from the environment exists a new session is created just like if we used the normal login endpoint.

## Testing
rspec tests for backend are included. Unit tests just require a working ruby installation w/ rspec. Integration tests require a running dev copy of ASpace. To set this up:

    git clone https://github.com/archivesspace/archivesspace.git
    cd archivesspace/plugins
    git clone https://github.com/mlibrary/aspace_remote_user.git
    cp aspace_remote_user/sample_config.rb ../common/config/config.rb
    build/run bootstrap
    build/run backend:devserver

Also see the ArchivesSpace build system [documentation](https://archivesspace.github.io/archivesspace/user/archivesspace-build-system/).
