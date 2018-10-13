require 'spec_helper'
require 'open3'
require 'json'

describe "commands:out" do

  let(:out_file) { '/opt/resource/out' }
  let(:mockelton_out) { '/resource/spec/fixtures/mockleton.out' }

  it('should exist') do
    expect(File).to exist(out_file)
    expect(File.stat(out_file).mode.to_s(8)[3..5]).to eq("755")
  end

  describe "integration" do

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
      expect(out["sequence"][0]["exec-spec"]["args"]).to eq [ "ansible-galaxy", "-r", "requirements.yml" ]
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
      expect(out["sequence"][0]["exec-spec"]["args"]).to eq [ "ansible-galaxy", "-r", "other_requirements.yml" ]
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
        "key",
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
        "key",
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
        "key",
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
        "key",
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
        "key",
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
        "key",
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
        "key",
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
        "key",
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
        "key",
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
        "key",
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
        "key",
        "-vv",
        "site.yml"
      ]
    end

  end

end
