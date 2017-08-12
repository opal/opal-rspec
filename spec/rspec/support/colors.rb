require 'io/console'

module Opal::RSpec::Colors
  extend self

  def color(text, color)
    console_code_for = {
      :black   => 30,
      :red     => 31,
      :green   => 32,
      :yellow  => 33,
      :blue    => 34,
      :magenta => 35,
      :cyan    => 36,
      :white   => 37,
      :bold    => 1,
    }
    console_code_for.default = console_code_for[:white]
    "\033" + "[#{console_code_for[color]}m#{text}" +"\033" + '[0m'
  end

  def patching text, filename = nil
    return unless $DEBUG
    filename = File.basename filename if filename
    text = "[patch][#{filename}] #{text}"
    _height, width = IO.console.winsize
    puts color(text.size > width ? text[0...width-1]+'…' : text, :cyan)
  end

  def running_file filename
    return unless $DEBUG
    puts color("[running] #{filename}", :yellow)
  end
end
