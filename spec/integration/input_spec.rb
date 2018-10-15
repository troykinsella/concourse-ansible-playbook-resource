require 'spec_helper'
require 'open3'
require 'json'

describe "integration:input" do

  let(:out_file) { '/opt/resource/out' }
  let(:mockelton_out) { '/resource/spec/fixtures/mockleton.out' }

  after(:each) do
    File.delete mockelton_out if File.exists? mockelton_out
  end

  it "requires params.path" do
    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => "{}")

    expect(status.success?).to be false
    expect(stderr).to eq %("params.path" must be defined\n)

  end

  it "requires params.path to exist" do
    stdin = {
        "params" => {
            "path" => "definitely_doesn't exist"
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be false
    expect(stderr).to eq %(params.path: "definitely_doesn't exist" does not exist\n)

  end

  it "requires source.ssh_private_key" do
    stdin = {
        "params" => {
            "path" => "spec/fixtures"
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be false
    expect(stderr).to eq %("source.ssh_private_key" must be defined\n)

  end

  it "requires params.inventory" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key"
        },
        "params" => {
            "path" => "spec/fixtures"
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be false
    expect(stderr).to eq %("params.inventory" must be defined\n)

  end

end
