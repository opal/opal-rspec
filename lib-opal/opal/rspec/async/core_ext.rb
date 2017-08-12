require 'promise'

module Kernel
  def exit(status = true)
    status = 0 if `status === true` # it's in JS because it can be null/undef

    $__at_exit__ ||= []
    process_promises = nil
    exit_block = -> { `Opal.exit(status)`; nil }

    next_at_exit = -> do
      if $__at_exit__.size > 0
        block = $__at_exit__.pop
        result =  block.call
        result.is_a?(Promise) ? result.then(&next_at_exit) : next_at_exit.call
      else
        result.is_a?(Promise) ? result.then(&exit_block) : exit_block.call
      end
    end

    next_at_exit.call
  end
end
