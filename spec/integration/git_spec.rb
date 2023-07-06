require 'spec_helper'
require 'open3'
require 'json'

describe "integration:git" do

  let(:out_file) { '/opt/resource/out' }
  let(:mockelton_out) { '/resource/spec/fixtures/mockleton.out' }
  let(:git_private_key_file) { '/tmp/ansible-playbook-resource-git-private-key' }
  let(:netrc_file) { '/root/.netrc' }
  let(:gitconfig_file) { '/root/.gitconfig' }

  after(:each) do
    File.delete mockelton_out if File.exist? mockelton_out
  end

  it "creates private key file" do
    stdin = {
        "source" => {
            "ssh_private_key" => "ssh_key",
            "git_private_key" => "git_key\n"
        },
        "params" => {
            "path" => "spec/fixtures",
            "inventory" => "the_inventory"
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true
    expect(File).to exist(git_private_key_file)

    git_private_key_contents = File.read git_private_key_file
    expect(git_private_key_contents).to eq("git_key\n")
  end

  it "configures ssl verification" do
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

  it "configures https credentials" do
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

  it "configures git globally" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key",
            "git_global_config" => {
                "user.name" => "foo",
                "user.email" => "foo@bar.com"
            }
        },
        "params" => {
            "path" => "spec/fixtures",
            "inventory" => "the_inventory"
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true
    expect(File).to exist(gitconfig_file)

    gitconfig_contents = File.read gitconfig_file
    expect(gitconfig_contents).to include("[user]\n\tname = foo\n\temail = foo@bar.com\n")
  end

  it "adds git key to ssh agent" do
    stdin = {
        "source" => {
            "ssh_private_key" => "ssh_key",
            "git_private_key" => "git_key",
            "debug" => true
        },
        "params" => {
            "path" => "spec/fixtures",
            "inventory" => "the_inventory"
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true
    out = JSON.parse(File.read(mockelton_out))

    expect(out["sequence"].size).to be 3
    expect(out["sequence"][0]["exec-spec"]["args"]).to eq [ "ssh-add", git_private_key_file ]
  end

end
