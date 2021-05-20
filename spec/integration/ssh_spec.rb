require 'spec_helper'
require 'open3'
require 'json'

describe "integration:ssh" do

  let(:out_file) { '/opt/resource/out' }
  let(:mockelton_out) { '/resource/spec/fixtures/mockleton.out' }
  let(:ssh_private_key_file) { '/tmp/ansible-playbook-resource-ssh-private-key' }
  let(:ssh_config) { '/root/.ssh/config' }

  after(:each) do
    File.delete mockelton_out if File.exists? mockelton_out
  end

  it "creates private key file" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key\n",
            "debug" => true
        },
        "params" => {
            "path" => "spec/fixtures",
            "inventory" => "the_inventory"
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true
    expect(File).to exist(ssh_private_key_file)

    ssh_private_key_contents = File.read ssh_private_key_file
    expect(ssh_private_key_contents).to eq("key\n")
  end

  it "adds trailing newline to private key file" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key",
            "debug" => true
        },
        "params" => {
            "path" => "spec/fixtures",
            "inventory" => "the_inventory"
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true
    expect(File).to exist(ssh_private_key_file)

    ssh_private_key_contents = File.read ssh_private_key_file
    expect(ssh_private_key_contents).to eq("key\n")
  end

  it "should create ssh config" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key\n"
        },
        "params" => {
            "path" => "spec/fixtures",
            "inventory" => "the_inventory"
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true
    expect(File).to exist(ssh_config)

    ssh_config_contents = File.read ssh_config
    expect(ssh_config_contents).to include("StrictHostKeyChecking no\n")
    expect(ssh_config_contents).to include("LogLevel quiet\n")
  end

end
