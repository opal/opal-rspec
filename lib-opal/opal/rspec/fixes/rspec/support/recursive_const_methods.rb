module ::RSpec::Support::RecursiveConstMethods
  def normalize_const_name(const_name)
    #const_name.sub(/\A::/, '')
    # the \A, which means 'beginning of string' does not work in Opal/JS regex, ^ is beginning of line, which for constant names, should work OK
    const_name.sub(/^::/, '')
  end
end
