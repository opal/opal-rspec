module RSpec
  module Core
    module Formatters
      class ExceptionPresenter
        def indent_lines(lines, failure_number)
          alignment_basis = ' ' * @indentation
          alignment_basis +=  "#{failure_number}) " if failure_number
          indentation = ' ' * alignment_basis.length

          lines.each_with_index.map do |line, index|
            if index == 0
              "#{alignment_basis}#{line}"
            elsif line.empty?
              line
            else
              "#{indentation}#{line}"
            end
          end
        end

        def fully_formatted(failure_number, colorizer=::RSpec::Core::Formatters::ConsoleCodes)
          lines = fully_formatted_lines(failure_number, colorizer)
          lines.join("\n") + "\n"
        end
      end
    end
  end
end
