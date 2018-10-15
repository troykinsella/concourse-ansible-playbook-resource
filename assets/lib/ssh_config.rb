
require 'open3'

class SSHConfig

  def initialize(echo = false)
    @echo = echo
  end

  def create_key_file!(key_path, key)
    File.write key_path, key
    FileUtils.chmod 0600, key_path
  end

  def ssh_add_key!(key_path)
    cmd = "SSH_ASKPASS=/opt/resource/lib/ssh_askpass.sh DISPLAY= ssh-add #{key_path}"
    puts cmd if @echo

    stdout, stderr, status = Open3.capture3(ENV, cmd)
    puts(stdout) if @echo
    STDERR.puts stderr

    raise "ssh-add failed" unless status.success?
  end

  def configure!
    ssh_dir = File.expand_path "~/.ssh"
    ssh_config_path = File.join(ssh_dir, "config")

    FileUtils.mkdir_p ssh_dir
    File.write ssh_config_path, <<~EOF
        StrictHostKeyChecking no
        LogLevel quiet
    EOF

    FileUtils.chmod 0600, ssh_config_path
  end

end
