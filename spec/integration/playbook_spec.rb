require 'spec_helper'
require 'open3'
require 'json'

describe "integration:playbook" do

  let(:out_file) { '/opt/resource/out' }
  let(:mockelton_out) { '/resource/spec/fixtures/mockleton.out' }
  let(:ssh_private_key_file) { '/tmp/ansible-playbook-resource-ssh-private-key' }

  after(:each) do
    File.delete mockelton_out if File.exists? mockelton_out
  end

  it "calls ansible-playbook with minimal arguments" do
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
    expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                              "ansible-playbook",
                                                              "-i",
                                                              "the_inventory",
                                                              "--private-key",
                                                              ssh_private_key_file,
                                                              "site.yml"
                                                          ]
  end

  it "calls ansible-playbook with param.become" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key"
        },
        "params" => {
            "path" => "spec/fixtures",
            "inventory" => "the_inventory",
            "become" => true
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true

    out = JSON.parse(File.read(mockelton_out))

    expect(out["sequence"].size).to be 2
    expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                              "ansible-playbook",
                                                              "--become",
                                                              "-i",
                                                              "the_inventory",
                                                              "--private-key",
                                                              ssh_private_key_file,
                                                              "site.yml"
                                                          ]
  end

  it "calls ansible-playbook with param.become_user" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key"
        },
        "params" => {
            "path" => "spec/fixtures",
            "inventory" => "the_inventory",
            "become_user" => "ted"
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true

    out = JSON.parse(File.read(mockelton_out))

    expect(out["sequence"].size).to be 2
    expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                              "ansible-playbook",
                                                              "--become-user",
                                                              "ted",
                                                              "-i",
                                                              "the_inventory",
                                                              "--private-key",
                                                              ssh_private_key_file,
                                                              "site.yml"
                                                          ]
  end

  it "calls ansible-playbook with param.become_user" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key"
        },
        "params" => {
            "path" => "spec/fixtures",
            "inventory" => "the_inventory",
            "become_method" => "sudo"
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true

    out = JSON.parse(File.read(mockelton_out))

    expect(out["sequence"].size).to be 2
    expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                              "ansible-playbook",
                                                              "--become-method",
                                                              "sudo",
                                                              "-i",
                                                              "the_inventory",
                                                              "--private-key",
                                                              ssh_private_key_file,
                                                              "site.yml"
                                                          ]
  end

  it "calls ansible-playbook with param.check" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key"
        },
        "params" => {
            "path" => "spec/fixtures",
            "inventory" => "the_inventory",
            "check" => true
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true

    out = JSON.parse(File.read(mockelton_out))

    expect(out["sequence"].size).to be 2
    expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                              "ansible-playbook",
                                                              "--check",
                                                              "-i",
                                                              "the_inventory",
                                                              "--private-key",
                                                              ssh_private_key_file,
                                                              "site.yml"
                                                          ]
  end

  it "calls ansible-playbook with param.diff" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key"
        },
        "params" => {
            "path" => "spec/fixtures",
            "inventory" => "the_inventory",
            "diff" => true
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true

    out = JSON.parse(File.read(mockelton_out))

    expect(out["sequence"].size).to be 2
    expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                              "ansible-playbook",
                                                              "--diff",
                                                              "-i",
                                                              "the_inventory",
                                                              "--private-key",
                                                              ssh_private_key_file,
                                                              "site.yml"
                                                          ]
  end

  it "calls ansible-playbook with source.remote_user" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key",
            "remote_user" => "reggie"
        },
        "params" => {
            "path" => "spec/fixtures",
            "inventory" => "the_inventory",
            "diff" => true
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true

    out = JSON.parse(File.read(mockelton_out))

    expect(out["sequence"].size).to be 2
    expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                              "ansible-playbook",
                                                              "--diff",
                                                              "-i",
                                                              "the_inventory",
                                                              "--private-key",
                                                              ssh_private_key_file,
                                                              "--remote-user",
                                                              "reggie",
                                                              "site.yml"
                                                          ]
  end

  it "calls ansible-playbook with source.ssh_common_args" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key",
            "ssh_common_args" => "-o foo"
        },
        "params" => {
            "path" => "spec/fixtures",
            "inventory" => "the_inventory",
            "diff" => true
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true

    out = JSON.parse(File.read(mockelton_out))

    expect(out["sequence"].size).to be 2
    expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                              "ansible-playbook",
                                                              "--diff",
                                                              "-i",
                                                              "the_inventory",
                                                              "--private-key",
                                                              ssh_private_key_file,
                                                              "--ssh-common-args",
                                                              "-o foo",
                                                              "site.yml"
                                                          ]
  end

  it "calls ansible-playbook with source.vault_password" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key",
            "vault_password" => "asdf"
        },
        "params" => {
            "path" => "spec/fixtures",
            "inventory" => "the_inventory",
            "diff" => true
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true

    out = JSON.parse(File.read(mockelton_out))

    expect(out["sequence"].size).to be 2
    expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                              "ansible-playbook",
                                                              "--diff",
                                                              "-i",
                                                              "the_inventory",
                                                              "--private-key",
                                                              ssh_private_key_file,
                                                              "--vault-password-file",
                                                              "/tmp/ansible-playbook-resource-ansible-vault-password",
                                                              "site.yml"
                                                          ]

    vp = File.read("/tmp/ansible-playbook-resource-ansible-vault-password")
    expect(vp).to eq "asdf"
  end

  it "calls ansible-playbook with param.vars" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key"
        },
        "params" => {
            "path" => "spec/fixtures",
            "inventory" => "the_inventory",
            "vars" => {
                "foo" => "bar",
                "baz" => [ "wokka" ],
                "biz" => {
                    "booze" => "yes please"
                }
            }
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true

    out = JSON.parse(File.read(mockelton_out))

    expect(out["sequence"].size).to be 2
    expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                              "ansible-playbook",
                                                              "--extra-vars",
                                                              '{"foo":"bar","baz":["wokka"],"biz":{"booze":"yes please"}}',
                                                              "-i",
                                                              "the_inventory",
                                                              "--private-key",
                                                              ssh_private_key_file,
                                                              "site.yml"
                                                          ]
  end

  it "calls ansible-playbook with source.verbose" do
    stdin = {
        "source" => {
            "ssh_private_key" => "key",
            "verbose" => "vv"
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
    expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                              "ansible-playbook",
                                                              "-i",
                                                              "the_inventory",
                                                              "--private-key",
                                                              ssh_private_key_file,
                                                              "-vv",
                                                              "site.yml"
                                                          ]
  end

end
