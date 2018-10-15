
class GitConfig

  def initialize(echo = false)
    @echo = echo
  end

  def skip_ssl_verification!(skip = true)
    if skip
      ENV['GIT_SSL_NO_VERIFY'] = "true"
    end
  end

  def configure_https_credentials!(username, password)
    if !username.nil? and !password.nil?
      netrc_path = File.expand_path "~/.netrc"
      File.write netrc_path, "default login #{username} #{password}\n"
      return true
    end
    false
  end

  def configure_git_global!(entries)
    (entries || {}).each do |key, value|
      cmd = "git config --global '#{key}' '#{value}'"
      puts cmd if @echo

      stdout, stderr, status = Open3.capture3(cmd)
      puts stdout
      STDERR.puts stderr

      raise "git config failed" unless status.success?
    end
  end

  # TODO: test git ssh key file and ssh-add -l
  # TODO: test git global config

end
