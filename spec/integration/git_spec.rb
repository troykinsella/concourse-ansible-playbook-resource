require 'spec_helper'
require 'open3'
require 'json'

describe "integration:git" do

  let(:out_file) { '/opt/resource/out' }
  let(:mockelton_out) { '/resource/spec/fixtures/mockleton.out' }
  let(:netrc_file) { '/root/.netrc' }

  after(:each) do
    File.delete mockelton_out if File.exists? mockelton_out
  end

  it "should configure ssl verification" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key",
            "git_skip_ssl_verification" => true
        },
        "params" => {
            "path" => "spec/fixtures",
            "inventory" => "the_inventory"
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true

    out = JSON.parse(File.read(mockelton_out))

    expect(out["sequence"].size).to be 2
    expect(out["sequence"][1]["exec-spec"]["env"]).to include("GIT_SSL_NO_VERIFY" => "true")
  end

  it "should configure https credentials" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key",
            "git_https_username" => "foo",
            "git_https_password" => "bar"
        },
        "params" => {
            "path" => "spec/fixtures",
            "inventory" => "the_inventory"
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true
    expect(File).to exist(netrc_file)

    netrc_contents = File.read netrc_file
    expect(netrc_contents).to include("default login foo bar\n")
  end

end
