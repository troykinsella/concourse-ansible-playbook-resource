
require 'json'

class AnsiblePlaybook

  attr_writer :become
  attr_writer :become_user
  attr_writer :become_method
  attr_writer :check
  attr_writer :diff
  attr_writer :env
  attr_writer :extra_vars
  attr_writer :inventory
  attr_writer :playbook
  attr_writer :private_key
  attr_writer :ssh_common_args
  attr_writer :user
  attr_writer :vault_password_file
  attr_writer :verbose

  def initialize(echo = false)
    @echo = echo
  end

  def become
    "--become" unless @become.nil?
  end

  def become_user
    "--become-user #{@become_user}" unless @become_user.nil?
  end

  def become_method
    "--become-method #{@become_method}" unless @become_method.nil?
  end

  def check
    "--check" if @check
  end

  def diff
    "--diff" if @diff
  end

  def env
    @env || {}
  end

  def extra_vars
    "--extra-vars '#{@extra_vars.to_json}'" unless @extra_vars.nil?
  end

  def inventory
    raise "inventory required" if @inventory.nil?
    "-i #{@inventory}"
  end

  def playbook
    @playbook || "site.yml"
  end

  def private_key
    "--private-key #{@private_key}" unless @private_key.nil?
  end

  def user
    "--user #{@user}" unless @user.nil?
  end

  def ssh_common_args
    "--ssh-common-args #{@ssh_common_args.to_json}" unless @ssh_common_args.nil?
  end

  def vault_password_file
    "--vault-password-file #{@vault_password_file}" unless @vault_password_file.nil?
  end

  def verbose
    "-#{@verbose}" unless @verbose.nil?
  end

  def command
    [
      "ansible-playbook",
      become,
      become_user,
      become_method,
      check,
      diff,
      extra_vars,
      inventory,
      private_key,
      ssh_common_args,
      user,
      vault_password_file,
      verbose,
      playbook
    ].join(" ")
  end

  def execute!
    cmd = command
    STDERR.puts cmd if @echo
    exec(env, cmd)
  end

end
