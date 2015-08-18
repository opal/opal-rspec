require 'rspec'
require 'opal/rspec/rake_task'
require 'rack'

describe Opal::RSpec::RakeTask do  
  let(:captured_opal_server) { {} }
    
  RSpec::Matchers.define :append_opal_path do |expected_path|
    def actual      
      captured_opal_server[:server].sprockets.paths
    end
    
    abs_expected = lambda { File.expand_path(expected_path) }
    
    match do
      actual.include? abs_expected.call
    end
    
    failure_message do
      "Expected paths #{actual} to include #{abs_expected.call}"
    end
    
    failure_message_when_negated do
      "Expected paths #{actual} to not include #{abs_expected.call}"
    end
  end
  
  before do
    if Rake::Task.tasks.map {|t| t.name}.include?(task_name.to_s) # Don't want prior examples to mess up state
      task = Rake::Task[task_name]
      task.clear
      task.reenable
    end
    allow(Rack::Server).to receive(:start) do |config| # don't want to actually run specs
      captured_opal_server[:server] = config[:app]
    end
    thread_double = instance_double Thread
    allow(thread_double).to receive :kill
    allow(Thread).to receive(:new) do |&block| # real threads would complicate specs
      block.call
      thread_double
    end
    allow(task_definition).to receive(:system) # don't actually call phantom
  end
  
  subject do
    task = task_definition
    Rake::Task[task_name].invoke
    task
  end
  
  context 'default' do
    let(:task_name) { :foobar }  
    let(:task_definition) do
      Opal::RSpec::RakeTask.new(task_name)
    end
    
    it { is_expected.to have_attributes pattern: 'spec/**/*_spec.{rb,opal}' }
    it { is_expected.to append_opal_path 'spec' }
    
    describe 'spec paths for runner' do
      subject { Opal::RSpec::RakeTask.get_opal_relative_specs }
      
      it { is_expected.to include 'after_hooks_spec', 'around_hooks_spec' }
    end
  end
  
  context 'custom pattern' do
    let(:task_name) { :bar }
    let(:task_definition) do
      Opal::RSpec::RakeTask.new(task_name) do |server, task|
        task.pattern = 'spec_other/**/*_spec.rb'
      end
    end
    
    it { is_expected.to have_attributes pattern: 'spec_other/**/*_spec.rb' }
    it { is_expected.to append_opal_path 'spec_other' }
    it { is_expected.to_not append_opal_path 'spec' }
    
    describe 'spec paths for runner' do
      subject { Opal::RSpec::RakeTask.get_opal_relative_specs }
      
      it { is_expected.to eq ['dummy_spec'] }
    end
  end
end
