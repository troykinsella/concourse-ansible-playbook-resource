#!/usr/bin/env ruby

require_relative '../ansible_galaxy'
require_relative '../ansible_playbook'
require_relative '../input'

require 'fileutils'

module Commands

  class Out

    attr_reader :destination
    attr_reader :input

    def initialize(destination:, input: Input.instance)
      @destination = destination
      @input = input
    end

    def source
      input.source
    end

    def require_source(name)
      v = source[name]
      raise InputError, %("source.#{name}" must be defined) if v.nil?
      v
    end

    def params
      input.params
    end

    def require_param(name)
      v = params[name]
      raise InputError, %("params.#{name}" must be defined) if v.nil?
      v
    end

    def path
      @path ||= begin
        p = File.join(destination, require_param('path'))
        raise InputError, %(params.path: "#{params.path}" does not exist) unless File.exist?(p)
        p
      end
    end

    def configure_ssh!
      key = require_source('ssh_private_key')
      key_path = "/tmp/ansible-playbook-resource-private-key"
      ssh_dir = "~/.ssh"
      ssh_config_path = File.join(ssh_dir, "config")

      File.write key_path, key
      FileUtils.chmod 0600, key_path

      FileUtils.mkdir_p ssh_dir
      File.write ssh_config_path, <<~EOF
        StrictHostKeyChecking no
        LogLevel quiet
      EOF

      FileUtils.chmod 0600, ssh_config_path
    end

    def create_vault_password_file!
      vp = source.vault_password
      if !vp.nil?
        vp_path = "/tmp/ansible-playbook-resource-ansible-vault-password"
        File.write vp_path, vp
        vp_path
      end
    end

    def install_requirements!
      ag = AnsibleGalaxy.new(source.debug)

      req = source.requirements
      if !req.nil?
        raise InputError, %(source.requirements: "#{source.requirements}" does not exist) unless File.exists? source.requirements
      end

      ag.requirements = req
      code = ag.install!
      exit(code) unless code == 0
    end

    def run_playbook!
      ap = AnsiblePlaybook.new(source.debug)

      ap.become = params.become
      ap.become_user = params.become_user
      ap.become_method = params.become_method
      ap.check = params.check
      ap.diff = params.diff
      ap.env = params.env
      ap.extra_vars = params.vars
      ap.inventory = require_param('inventory')
      ap.playbook = params.playbook

      ap.private_key = source.ssh_private_key
      ap.remote_user = source.remote_user
      ap.ssh_common_args = source.ssh_common_args
      ap.vault_password_file = create_vault_password_file!
      ap.verbose = source.verbose

      ap.execute!
    end

    def run!
      Dir.chdir(path)

      configure_ssh!
      install_requirements!
      run_playbook!
    end

  end

end

if $PROGRAM_NAME == __FILE__
  command = Commands::Out.new(destination: ARGV.shift)
  begin
    command.run!
  rescue InputError => e
    STDERR.puts e.message
    exit(1)
  end
end
