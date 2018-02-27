#require_relative "../backend/controllers/users"
require "trusted_login_endpoint"
require "ostruct"

class MockPlugin

  def json_response(hash,status=200)
    ""
  end

  def env
    {}
  end

  def params
    {username: "admin"}
  end

  def create_session_for(_,_)
    OpenStruct.new(id: 1)
  end

  class User
    def self.find(params)
      OpenStruct.new(permissions: "some_value") if params[:username] == "admin"
    end

    def self.to_jsonmodel(*)
      OpenStruct.new(some_key: "another_value")
    end
  end

  include MLibrary

  alias_method :real_login, :do_login_trusted
  def do_login_trusted
    real_login(user_class: User)
  end
end


RSpec.describe "MLibrary#do_login_trusted" do

  let(:plugin) {MockPlugin.new}
  
  it "responds with 403 if env['HTTP_X_FORWARDED_SERVER']" do
    allow(plugin).to receive(:env).and_return({'HTTP_X_FORWARDED_SERVER'=>true})
    expect(plugin).to receive(:json_response).with(anything, 403)
    plugin.do_login_trusted
  end

  it "responds with 403 if user not found" do
    allow(plugin).to receive(:params).and_return({:username=>'fakeuser'})
    expect(plugin).to receive(:json_response).with(anything, 403)
    plugin.do_login_trusted
  end

  it "responds with user object if user found" do
    expect(plugin).to receive(:json_response).with({:session => 1, :user => OpenStruct.new(some_key: "another_value", permissions: "some_value") })
    plugin.do_login_trusted
  end

  xit "responds with 403 if correct secret is not supplied" do
    expect(plugin).to receive(:json_response).with(anything, 403)
    plugin.do_login_trusted
  end

end

