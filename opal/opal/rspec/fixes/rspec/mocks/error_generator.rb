module ::RSpec::Mocks
  class ErrorGenerator
    def actual_method_call_args_description(count, args)
      method_call_args_description(args) ||
          if count > 0 && args.length > 0
            # \A and \z not supported on Opal
            # " with arguments: #{args.inspect.gsub(/\A\[(.+)\]\z/, '(\1)')}"
            " with arguments: #{args.inspect.gsub(/^\[(.+)\]$/, '(\1)')}"
          else
            ""
          end
    end
  end
end
