#!/usr/bin/env ruby

require_relative '../ansible_galaxy'
require_relative '../ansible_playbook'
require_relative '../git_config'
require_relative '../input'
require_relative '../ssh_config'

require 'fileutils'

module Commands

  class Out

    SSH_KEY_PATH = "/tmp/ansible-playbook-resource-ssh-private-key"
    GIT_KEY_PATH = "/tmp/ansible-playbook-resource-git-private-key"

    attr_reader :destination
    attr_reader :input

    def initialize(destination:, input: Input.instance)
      @destination = destination
      @input = input

      @ssh_config = SSHConfig.new source.debug
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
      debug "Configuring ssh..."
      key = require_source 'ssh_private_key'
      @ssh_config.create_key_file! SSH_KEY_PATH, key
      @ssh_config.configure!
    end

    def configure_git!
      debug "Configuring git..."
      key = source.git_private_key
      if !key.nil?
        @ssh_config.create_key_file! GIT_KEY_PATH, key
        @ssh_config.ssh_add_key! GIT_KEY_PATH
      end

      git_config = GitConfig.new source.debug
      git_config.skip_ssl_verification! source.git_skip_ssl_verification
      git_config.configure_https_credentials! source.git_https_username, source.git_https_password
      git_config.configure_git_global! source.git_global_config
    end

    def configure_ansible!
      # Sanitize ansible.cfg
      ansible_cfg_path = "ansible.cfg"
      if File.exists? ansible_cfg_path
        debug "Sanitizing ansible.cfg..."

        # Never allow a vault password file that may have come from source control :P
        `sed -i '/vault_password_file[[:space:]]*=/d' #{ansible_cfg_path}`

        # Never allow a private key file that may have come from source control :P
        `sed -i '/private_key_file[[:space:]]*=/d' #{ansible_cfg_path}`

        # Never prompt for a vault password
        `sed -i '/ask_vault_pass[[:space:]]*=/d' #{ansible_cfg_path}`

        # Never prompt for a become password
        `sed -i '/become_ask_pass[[:space:]]*=/d' #{ansible_cfg_path}`

        # Force certain ansible-playbook command line options to take
        # precedence over ansible.cfg entries
        if params.become
          `sed -i '/become[[:space:]]*=/d' #{ansible_cfg_path}`
        end
        if !params.become_method.nil?
          `sed -i '/become_method[[:space:]]*=/d' #{ansible_cfg_path}`
        end
        if !params.become_user.nil?
          `sed -i '/become_user[[:space:]]*=/d' #{ansible_cfg_path}`
        end
        if !params.inventory.nil?
          `sed -i '/inventory[[:space:]]*=/d' #{ansible_cfg_path}`
        end
        if !source.user.nil?
          `sed -i '/remote_user[[:space:]]*=/d' #{ansible_cfg_path}`
        end
        if !source.verbose.nil?
          `sed -i '/verbosity[[:space:]]*=/d' #{ansible_cfg_path}`
        end

        if source.debug
          puts "Sanitized ansible.cfg:"
          puts File.read(ansible_cfg_path)
          puts
        end
      end
    end

    def create_vault_password_file!
      vp = source.vault_password
      if !vp.nil?
        vp_path = "/tmp/ansible-playbook-resource-ansible-vault-password"
        File.write vp_path, vp

        debug "Wrote vault password file: #{vp_path}"

        vp_path
      end
    end

    def install_requirements!
      ag = AnsibleGalaxy.new source.debug

      req = source.requirements
      if !req.nil?
        raise InputError, %(source.requirements: "#{source.requirements}" does not exist) unless File.exists? source.requirements
      end

      ag.requirements = req
      ag.verbose = source.verbose
      code = ag.install!
      exit(code) unless code == 0
    end

    def run_setup_commands!
      (params.setup_commands || []).each do |setup_command|
        debug "Running setup command: #{setup_command}"

        system setup_command
      end
    end

    def run_playbook!
      debug "Executing ansible-playbook..."

      ap = AnsiblePlaybook.new source.debug

      ap.become = params.become
      ap.become_user = params.become_user
      ap.become_method = params.become_method
      ap.check = params.check
      ap.diff = params.diff
      ap.env = ENV.to_hash.merge(source.env || {})
      ap.extra_vars = params.vars
      ap.limit = params.limit
      ap.inventory = require_param 'inventory'
      ap.playbook = params.playbook
      ap.private_key = SSH_KEY_PATH
      ap.tags = params.tags
      ap.user = source.user
      ap.skip_tags = params.skip_tags
      ap.ssh_common_args = source.ssh_common_args
      ap.vault_password_file = create_vault_password_file!
      ap.verbose = source.verbose

      ap.execute!
    end

    def debug(msg)
      puts(msg) if source.debug
    end

    def run!
      Dir.chdir path

      configure_ssh!
      configure_git!
      configure_ansible!
      run_setup_commands!
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
