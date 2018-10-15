require 'spec_helper'
require 'open3'
require 'json'

describe "integration:ssh" do

  let(:out_file) { '/opt/resource/out' }
  let(:mockelton_out) { '/resource/spec/fixtures/mockleton.out' }
  let(:ssh_config) { '/root/.ssh/config' }

  after(:each) do
    File.delete mockelton_out if File.exists? mockelton_out
  end

  it "should create ssh config" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key"
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
