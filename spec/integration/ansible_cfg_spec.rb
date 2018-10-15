require 'spec_helper'
require 'open3'
require 'json'

describe "integration:ansible.cfg" do

  let(:out_file) { '/opt/resource/out' }
  let(:ansible_cfg_file) { 'spec/fixtures/ansible.cfg' }

  before(:each) do
    `cp #{ansible_cfg_file}.template #{ansible_cfg_file}`
  end

  after(:each) do
    File.delete ansible_cfg_file
  end

  it "gets sanitized" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key",
            "user" => "foo",
            "verbose" => "vv"
        },
        "params" => {
            "become" => true,
            "become_user" => "foo",
            "become_method" => "sudo",
            "path" => "spec/fixtures",
            "inventory" => "the_inventory"
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true

    cfg = File.read ansible_cfg_file
    expect(cfg).to_not include("bad!")
  end
end
