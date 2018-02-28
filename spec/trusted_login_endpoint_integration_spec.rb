require "curb"

BACKEND_HOST="localhost"
BACKEND_PORT=4567
USER="admin"
PRIVATE_API_PASSWORD="YOU_MUST_CHANGE_THIS" # don't actually change this, it just needs to match the included sample config
HTTP_PROXY_HEADER="X-FORWARDED-SERVER"


RSpec.describe "aspace_remote_user" do

  let(:curl) {
    Curl::Easy.new("http://#{BACKEND_HOST}:#{BACKEND_PORT}/users/#{USER}/login/trusted")
  }

  it "responds with status 200 with correctly formed request" do
    curl.http_post(Curl::PostField.content("password",PRIVATE_API_PASSWORD))
    expect(curl.response_code).to eq(200)
  end

  it "responds with status 403 if HTTP_PROXY_HEADER is set" do
    curl.headers[HTTP_PROXY_HEADER]="anything_at_all"
    curl.http_post(Curl::PostField.content("password",PRIVATE_API_PASSWORD))
    expect(curl.response_code).to eq(403)
  end

  it "responds with status 403 if user not found" do
    curl = Curl::Easy.new("http://#{BACKEND_HOST}:#{BACKEND_PORT}/users/fake_user/login/trusted")
    curl.http_post(Curl::PostField.content("password",PRIVATE_API_PASSWORD))
    expect(curl.response_code).to eq(403)
  end

  it "responds with status 400 if password is missing" do
    curl.http_post
    expect(curl.response_code).to eq(400)
  end

  it "responds with status 403 if password is incorrect" do
    curl.http_post(Curl::PostField.content("password","wrong_password"))
    expect(curl.response_code).to eq(403)
  end

end

