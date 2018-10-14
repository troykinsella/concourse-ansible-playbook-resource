
class AnsibleGalaxy

  attr_writer :requirements

  def initialize(echo = false)
    @echo = echo
  end

  def requirements
    @requirements || "requirements.yml"
  end

  def install_command
    "ansible-galaxy install -r #{requirements}"
  end

  def install!
    return 0 unless File.exists? requirements

    cmd = install_command
    STDERR.puts cmd if @echo
    system(cmd)
    $?.exitstatus
  end

end
