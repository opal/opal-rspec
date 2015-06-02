# describe 'around hooks' do
#   before do
#     @model = Object.new
#     @test_in_progress = nil
#   end
#
#   before :all do
#     @@around_testing = []
#     @@around_failures = []
#   end
#
#   around do |example|
#     look_for = example.description
#     @@around_testing << look_for
#     # Result is the result of the test, aka the promised value from run (true if success, false if failed)
#     # The complete_promise is needed so the runner knows when to continue
#     example.run.then do |result, complete_promise|
#       last = @@around_testing.pop
#       @@around_failures << "Around hook kept executing even though test #{@test_in_progress} was running!" if @test_in_progress
#       @@around_failures << "Around hooks are messed up because we expected #{look_for} but we popped off #{last}" unless last == look_for
#       complete_promise.resolve
#     end
#   end
#
#   after :all do
#     raise @@around_failures.join "\n" if @@around_failures.any?
#     raise 'hooks not empty!' unless @@around_testing.empty?
#   end
#
#   it 'is an async test' do
#     delay_with_promise 0 do
#       1.should == 1
#     end
#   end
#
#   it 'works with a sync test in a group of async tests with an around hook' do
#     1.should == 1
#   end
#
#   it 'is another async test' do
#     delay_with_promise 0 do
#       1.should == 1
#     end
#   end
# end
