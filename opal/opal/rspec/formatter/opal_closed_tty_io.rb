class OpalClosedTtyIO < IO
  include IO::Writable

  def initialize(runner_type, io_type)
    raise "Unknown IO type #{io_type}!" unless [:stdout, :stderr].include?(io_type)
    self.write_proc = case runner_type
                        when :phantom
                          `function(str){callPhantom([#{io_type}, str])}`
                        when :node, :browser
                          # opal io is already node aware, browser works as well, but we can't do anything about puts vs. print with the browser
                          case io_type
                            when :stdout
                              $stdout.write_proc
                            when :stderr
                              $stderr.write_proc
                          end
                        else
                          raise "Unknown runner type #{runner_type}"
                      end
    @tty = true
  end

  # We're deferring to stdout here, which doesn't need to be closed, but RSpec::BaseTextFormatter doesn't know that, so override this
  def closed?
    true
  end
end
