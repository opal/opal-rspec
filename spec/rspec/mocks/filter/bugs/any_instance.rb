rspec_filter filter '#any_instance' do
  filter '#any_instance when used after the test has finished restores the original behaviour, even if the expectation fails'
  filter '#any_instance when used after the test has finished restores the original behavior of a stubbed method'
  filter '#any_instance when directed at a method defined on a superclass mocks the method correctly'
  filter '#any_instance when resetting post-verification existing method with stubbing private methods restores a stubbed private method after the spec is run'
  filter '#any_instance when resetting post-verification existing method with expectations private methods restores a stubbed private method after the spec is run'
  filter '#any_instance passing the receiver to the implementation block when configured to pass the instance an any instance stub does not pass the instance to and_call_original'
  filter '#any_instance setting a message expectation with an expectation is set on a method that exists after any one instance has received a message fails if the method is invoked on a second instance'
  filter "#any_instance setting a message expectation with an expectation is set on a method which does not exist behaves as 'exactly one instance' fails if the method is invoked on a second instance"
  filter('#any_instance setting a message expectation works with a SimpleDelegator subclass').unless { at_least_opal_0_9? }
  filter "#any_instance when stubbing behaves as 'every instance' handles freeze and duplication correctly"
  filter "#any_instance when stubbing behaves as 'every instance' handles method restoration on subclasses"
  filter /#any_instance when stubbing with #and_call_original and competing #with can combine and_call_original, with, and_return.*/
  filter("#any_instance when stubbing with #and_raise can stub a method that doesn't exist").unless { at_least_opal_0_9? }
  filter('#any_instance when stubbing with #and_raise can stub a method that exists').unless { at_least_opal_0_9? }
  filter '#any_instance when stubbing when partially mocking objects resets partially mocked objects correctly'
  filter '#any_instance unstubbing using `and_call_original` replaces the stubbed method with the original method'
  filter '#any_instance unstubbing using `and_call_original` removes all stubs with the supplied method name'
  filter '#any_instance unstubbing using `and_call_original` removes stubs even if they have already been invoked'
  filter '#any_instance unstubbing using `and_call_original` removes stubs from sub class after invokation when super class was originally stubbed'
  filter '#any_instance unstubbing using `and_call_original` removes any stubs set directly on an instance'
  filter '#any_instance unstubbing using `and_call_original` does not get confused about string vs symbol usage for the message'
  filter("#any_instance when stubbing behaves as 'every instance' handles stubbing on super and subclasses").if { at_least_opal_0_9? }
end
