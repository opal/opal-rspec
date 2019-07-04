Opal::RSpec::UpstreamTests::Result = Struct.new(:command, :exit_status, :output, :json) do
  def quoted_output
    "> "+output.gsub(/(\n)/, '\1> ')
  end

  def successful?
    exit_status == 0
  end

  def inspect
    "#<struct #{self.class.name} command=#{command.inspect} exit_status=#{exit_status} summary=#{json[:summary_line].inspect}>"
  end

  alias to_s inspect
end
