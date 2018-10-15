require 'spec_helper'
require 'open3'
require 'json'

describe "integration:requirments" do

  let(:out_file) { '/opt/resource/out' }
  let(:mockelton_out) { '/resource/spec/fixtures/mockleton.out' }

  after(:each) do
    File.delete mockelton_out if File.exists? mockelton_out
  end

  it "installs default requirements" do
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

    out = JSON.parse(File.read(mockelton_out))

    expect(out["sequence"].size).to be 2
    expect(out["sequence"][0]["exec-spec"]["args"]).to eq [ "ansible-galaxy", "install", "-r", "requirements.yml" ]
  end

  it "installs specified requirements" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key",
            "requirements" => "other_requirements.yml"
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
    expect(out["sequence"][0]["exec-spec"]["args"]).to eq [ "ansible-galaxy", "install", "-r", "other_requirements.yml" ]
  end

  it "installs requirements with specified verbosity" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key",
            "requirements" => "other_requirements.yml",
            "verbose" => "vvv"
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
    expect(out["sequence"][0]["exec-spec"]["args"]).to eq [ "ansible-galaxy", "install", "-vvv", "-r", "other_requirements.yml" ]
  end

  it "fails when requirements not found" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key",
            "requirements" => "bogus_requirements.yml"
        },
        "params" => {
            "path" => "spec/fixtures",
            "inventory" => "the_inventory"
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be false
    expect(stderr).to eq %(source.requirements: "bogus_requirements.yml" does not exist\n)
  end


end
