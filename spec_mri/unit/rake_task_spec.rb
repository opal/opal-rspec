require 'rspec'
require 'opal/rspec/rake_task'
require 'rack'

describe Opal::RSpec::RakeTask do
  RSpec::Matchers.define :set_pattern_env do |matcher|
    def actual
      ENV['PATTERN']
    end
    
    match do
      matcher.matches? actual
    end
    
    failure_message do
      matcher.failure_message
    end
  end
  
  before do
    allow(Rack::Server).to receive(:start) # don't want to actually run specs
  end
  
  subject do
    task = task_definition
    begin
      Rake::Task[task_name].invoke
    rescue SystemExit
      # Expected failure since we disabled rack
    end
    task
  end
  
  context 'default' do
    let(:task_name) { :foobar }  
    let(:task_definition) do
      Opal::RSpec::RakeTask.new(task_name)
    end
    
    it { is_expected.to have_attributes pattern: 'spec/**/*_spec.{rb,opal}' }
    it { is_expected.to set_pattern_env eq 'spec/**/*_spec.{rb,opal}'}
  end
  
  context 'custom pattern' do
    pending 'write this'
  end
end
