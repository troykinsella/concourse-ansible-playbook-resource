
class AnsibleGalaxy

  attr_writer :requirements
  attr_writer :verbose

  def initialize(echo = false)
    @echo = echo
  end

  def requirements
    @requirements || "requirements.yml"
  end

  def verbose
    "-#{@verbose}" unless @verbose.nil?
  end

  def install_command
    "ansible-galaxy install #{verbose} -r #{requirements}"
  end

  def install!
    return 0 unless File.exist? requirements

    cmd = install_command
    STDERR.puts cmd if @echo
    system(cmd)
    $?.exitstatus
  end

end
