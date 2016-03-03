rspec_filter 'and_call_original' do
  # any_instance related
  filter 'and_call_original on a partial double when using any_instance works for instance methods defined on the class'
  filter 'and_call_original on a partial double when using any_instance works for instance methods defined on the superclass of the class'
  filter 'and_call_original on a partial double when using any_instance works when mocking the method on one class and calling the method on an instance of a subclass'
  filter 'and_call_original on a partial double on an object that defines method_missing works for an any_instance partial mock'
  filter 'and_call_original on a partial double on an object that defines method_missing raises an error for an unhandled message for an any_instance partial mock'

  # SimpleDelegator
  filter 'and_call_original on a partial double for singleton methods works for SimpleDelegator subclasses'
end
