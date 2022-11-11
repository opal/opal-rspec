unless File.respond_to? :read
  def File.read(*)
    raise Errno::ENOENT
  end
end
