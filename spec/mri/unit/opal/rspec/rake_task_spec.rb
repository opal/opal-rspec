require 'rspec'
require 'opal/rspec/rake_task'
require 'rack'
require_relative 'temp_dir_helper'

describe Opal::RSpec::RakeTask do
  include_context :temp_dir 
  let(:captured_opal_server) { {} }
    
  RSpec::Matchers.define :require_opal_specs do |matcher|
    def actual
      captured_opal_server[:server].sprockets.cached.get_opal_spec_requires    
    end
    
    match do
      matcher.matches? actual
    end
    
    failure_message do
      matcher.failure_message
    end
    
    failure_message_when_negated do
      matcher.failure_message_when_negated
    end
  end
    
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
    allow(task_definition).to receive(:launch_phantom).and_return(nil) # don't actually call phantom
  end
  
  let(:task_name) { :foobar }
  
  subject do
    task = task_definition
    Rake::Task[task_name].invoke
    task
  end
  
  context 'default' do
    let(:task_definition) do
      Opal::RSpec::RakeTask.new(task_name)
    end
    
    before do
      create_dummy_spec_files 'spec/something/dummy_spec.rb'
    end
    
    it { is_expected.to have_attributes pattern: nil }
    it { is_expected.to append_opal_path 'spec' }
    it { is_expected.to require_opal_specs eq ['something/dummy_spec'] }
  end
  
  context 'pattern' do
    let(:task_definition) do
      Opal::RSpec::RakeTask.new(task_name) do |server, task|
        task.pattern = 'spec/other/**/*_spec.rb'
      end
    end
    
    before do
      create_dummy_spec_files 'spec/other/dummy_spec.rb'
    end
  
    it { is_expected.to have_attributes pattern: 'spec/other/**/*_spec.rb' }
    it { is_expected.to append_opal_path 'spec/other' }
    it { is_expected.to_not append_opal_path 'spec' }
    it { is_expected.to require_opal_specs eq ['dummy_spec'] }   
  end
  
  context 'files' do
    let(:task_definition) do
      Opal::RSpec::RakeTask.new(task_name) do |server, task|
        task.files = FileList['spec/other/**/*_spec.rb']
      end
    end
    
    before do
      create_dummy_spec_files 'spec/other/dummy_spec.rb'
    end
  
    it { is_expected.to have_attributes files: FileList['spec/other/**/*_spec.rb'] }
    it { is_expected.to_not append_opal_path 'spec' }
    it { is_expected.to append_opal_path 'spec/other' }
    it { is_expected.to require_opal_specs eq ['dummy_spec'] }
  end  
  
  context 'pattern and files' do
    let(:task_definition) do
      Opal::RSpec::RakeTask.new(task_name) do |server, task|
        task.files = FileList['spec/other/**/*_spec.rb', 'util/**/*.rb']
        task.pattern = 'spec/opal/**/*hooks_spec.rb'
      end
    end
    
    subject do
      lambda {
        task = task_definition
        Rake::Task[task_name].invoke
        task
      }
    end
    
    it { is_expected.to raise_exception 'Cannot supply both a pattern and files!' }
  end
end
