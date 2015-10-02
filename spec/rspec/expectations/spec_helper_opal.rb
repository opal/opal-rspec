module FormattingSupport
  def dedent(string)
    string.gsub(/^\s+\|/, '').chomp
  end
end


# Can't use subprocesses, etc.
module MinitestIntegration
  def with_minitest_loaded
    yield
  end
end
