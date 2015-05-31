class Opal::RSpec::AsyncExample < ::RSpec::Core::Example
  def initialize(example_group_class, description, user_metadata, example_block, promise)
    super
    # wrapped_block = lambda do |example|
    #   done = lambda do
    #     @promise.resolve true
    #   end
    #   self.instance_exec(done, example, &example_block)
    # end
    # super example_group_class, description, user_metadata, wrapped_block
    @promise = promise
        # options = ::RSpec::Core::Metadata.build_hash_from(args)
  #           promise = Promise.new
  #
  #           wrapped_block = lambda do |example|
  #             done = lambda do
  #               promise.resolve true
  #             end
  #             puts 'running instance exec here'
  #             self.instance_exec(done, example, &block)
  #           end
  #           examples << RSpec::AsyncExample.new(self, desc, options, wrapped_block, promise)
  end

  # def run(example_group_instance, reporter)
  #   begin
  #     puts 'running super from async example'
  #     result = super
  #     puts "got back result #{result}"
  #     # If finish returned a false result, we have an exception, so don't bother with the promise
  #     result ? @promise : result
  #   rescue Exception => e
  #     puts "got exc #{e}"
  #   end
  # end
end
