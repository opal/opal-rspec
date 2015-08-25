require 'rspec'
require 'opal/rspec/rake_task'
require 'rack'

describe Opal::RSpec::RakeTask do  
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
    
    it { is_expected.to have_attributes pattern: nil }
    it { is_expected.to append_opal_path 'spec' }
    it { is_expected.to require_opal_specs include('opal/after_hooks_spec', 'opal/around_hooks_spec', 'mri/integration/browser_spec') }
  end
  
  context 'pattern' do
    context 'single inclusion' do
      let(:task_definition) do
        Opal::RSpec::RakeTask.new(task_name) do |server, task|
          task.pattern = 'spec/other/**/*_spec.rb'
        end
      end
    
      it { is_expected.to have_attributes pattern: 'spec/other/**/*_spec.rb' }
      it { is_expected.to append_opal_path 'spec/other' }
      it { is_expected.to_not append_opal_path 'spec' }
      it { is_expected.to require_opal_specs eq ['dummy_spec'] }   
    end
  
    context 'single exclusion' do
      let(:task_definition) do
        Opal::RSpec::RakeTask.new(task_name) do |server, task|
          task.exclude_pattern = '**/*/*_hooks_spec.rb'
        end
      end
    
      it { is_expected.to have_attributes pattern: nil }
      it { is_expected.to have_attributes exclude_pattern: '**/*/*_hooks_spec.rb' }
      it { is_expected.to append_opal_path 'spec' }
      it { is_expected.to require_opal_specs include('mri/integration/browser_spec') }
      it { is_expected.to_not require_opal_specs include('opal/after_hooks_spec', 'opal/around_hooks_spec') }
    end
  
    context 'multiple inclusion' do
      context 'same base path' do
        let(:task_definition) do
          Opal::RSpec::RakeTask.new(task_name) do |server, task|
            # implicit default inclusion pattern
            task.pattern = ['spec/opal/**/*hooks_spec.rb', 'spec/opal/**/matchers_spec.rb']
          end
        end
    
        it { is_expected.to have_attributes pattern: ['spec/opal/**/*hooks_spec.rb', 'spec/opal/**/matchers_spec.rb'] }
        it { is_expected.to append_opal_path 'spec/opal' }
        it { is_expected.to_not append_opal_path 'spec' }
        it { is_expected.to require_opal_specs eq ['after_hooks_spec', 'around_hooks_spec', 'before_hooks_spec', 'matchers_spec'] }   
      end
      
      context 'multiple base paths, same root' do
        let(:task_definition) do
          Opal::RSpec::RakeTask.new(task_name) do |server, task|
            # implicit default inclusion pattern
            task.pattern = ['spec/opal/**/*hooks_spec.rb', 'spec/other/**/*_spec.rb']
          end
        end
    
        it { is_expected.to have_attributes pattern: ['spec/opal/**/*hooks_spec.rb', 'spec/other/**/*_spec.rb'] }
        it { is_expected.to append_opal_path 'spec' }
        it { is_expected.to require_opal_specs eq ['opal/after_hooks_spec', 'opal/around_hooks_spec', 'opal/before_hooks_spec', 'other/dummy_spec'] }   
      end
      
      context 'multiple base paths, different root' do
        let(:task_definition) do
          Opal::RSpec::RakeTask.new(task_name) do |server, task|
            # implicit default inclusion pattern
            task.pattern = ['spec/other/**/*_spec.rb', 'util/**/*.rb']
          end
        end
    
        it { is_expected.to have_attributes pattern: ['spec/other/**/*_spec.rb', 'util/**/*.rb'] }
        it { is_expected.to append_opal_path 'spec/other' }
        it { is_expected.to append_opal_path 'util' }
        it { is_expected.to_not append_opal_path 'spec' }
        it { is_expected.to require_opal_specs eq ['dummy_spec', 'create_requires'] }
      end
      
      context 'multiple base paths, same directory name in middle' do
        let(:task_definition) do
          Opal::RSpec::RakeTask.new(task_name) do |server, task|
            task.pattern = ['rspec-core/spec/**/*_spec.rb', 'spec/rspec_provided/rspec_spec_fixes.rb']
          end
        end
    
        it { is_expected.to have_attributes pattern: ['rspec-core/spec/**/*_spec.rb', 'spec/rspec_provided/rspec_spec_fixes.rb'] }
        it { is_expected.to append_opal_path 'rspec-core/spec' }
        it { is_expected.to append_opal_path 'spec/rspec_provided' }
        it { is_expected.to_not append_opal_path 'spec' }
        it { is_expected.to require_opal_specs include('rspec_spec_fixes', 'rspec/core_spec') }
      end
    end
  
    context 'multiple exclusion' do
      let(:task_definition) do
        Opal::RSpec::RakeTask.new(task_name) do |server, task|
          task.exclude_pattern = ['**/*/*_hooks_spec.rb', '**/*/a*_spec.rb']
        end
      end
    
      it { is_expected.to have_attributes exclude_pattern: ['**/*/*_hooks_spec.rb', '**/*/a*_spec.rb'] }
      it { is_expected.to append_opal_path 'spec' }
      it { is_expected.to require_opal_specs include('mri/integration/browser_spec') }
      it { is_expected.to_not require_opal_specs include(/.*hooks/, /a.*/) }
    end
  end
  
  context 'files' do
    context 'single file' do
      let(:task_definition) do
        Opal::RSpec::RakeTask.new(task_name) do |server, task|
          task.files = FileList['spec/other/**/*_spec.rb']
        end
      end
    
      it { is_expected.to have_attributes files: FileList['spec/other/**/*_spec.rb'] }
      it { is_expected.to_not append_opal_path 'spec' }
      it { is_expected.to append_opal_path 'spec/other' }
      it { is_expected.to require_opal_specs eq ['dummy_spec'] }
    end
    
    context 'multiple files' do
      let(:task_definition) do
        Opal::RSpec::RakeTask.new(task_name) do |server, task|
          task.files = FileList['spec/other/**/*_spec*']
        end
      end
    
      it { is_expected.to have_attributes files: FileList['spec/other/**/*_spec*'] }
      it { is_expected.to_not append_opal_path 'spec' }
      it { is_expected.to append_opal_path 'spec/other' }
      it { is_expected.to require_opal_specs eq ['dummy_spec', 'ignored_spec'] }
    end
    
    context 'absolute path and relative path that are not in the same tree' do
      let(:tmp_spec_dir) { Dir.mktmpdir }
      
      let(:dummy_spec) do
        fake_spec = File.join tmp_spec_dir, 'junk_spec.rb'
        FileUtils.touch fake_spec
        fake_spec
      end
      
      after do
        FileUtils.remove_entry tmp_spec_dir
      end
      
      let(:task_definition) do
        Opal::RSpec::RakeTask.new(task_name) do |server, task|
          task.files = FileList['spec/other/**/*_spec.rb', dummy_spec]
        end
      end
      
      it { is_expected.to append_opal_path 'spec/other' }
      it { is_expected.to append_opal_path tmp_spec_dir }
      it { is_expected.to require_opal_specs eq ['dummy_spec', 'junk_spec'] }
    end
    
    context 'multiple base paths, same root' do
      let(:task_definition) do
        Opal::RSpec::RakeTask.new(task_name) do |server, task|
          task.files = FileList['spec/opal/**/*hooks_spec.rb', 'spec/other/**/*_spec.rb']
        end
      end
  
      it { is_expected.to have_attributes files: FileList['spec/opal/**/*hooks_spec.rb', 'spec/other/**/*_spec.rb'] }
      it { is_expected.to append_opal_path 'spec' }
      it { is_expected.to require_opal_specs eq ['opal/after_hooks_spec', 'opal/around_hooks_spec', 'opal/before_hooks_spec', 'other/dummy_spec'] }   
    end
    
    context 'multiple base paths, different root' do
      let(:task_definition) do
        Opal::RSpec::RakeTask.new(task_name) do |server, task|
          task.files = FileList['spec/other/**/*_spec.rb', 'util/**/*.rb']
        end
      end
  
      it { is_expected.to have_attributes files: FileList['spec/other/**/*_spec.rb', 'util/**/*.rb'] }
      it { is_expected.to append_opal_path 'spec/other' }
      it { is_expected.to append_opal_path 'util' }
      it { is_expected.to_not append_opal_path 'spec' }
      it { is_expected.to require_opal_specs eq ['dummy_spec', 'create_requires'] }
    end
    
    context 'multiple base paths, same directory name in middle' do
      let(:task_definition) do
        Opal::RSpec::RakeTask.new(task_name) do |server, task|
          task.files = FileList['spec/rspec_provided/rspec_spec_fixes.rb', 'rspec-core/spec/**/*_spec.rb']
        end
      end
  
      it { is_expected.to have_attributes files: FileList['spec/rspec_provided/rspec_spec_fixes.rb', 'rspec-core/spec/**/*_spec.rb'] }
      it { is_expected.to append_opal_path 'rspec-core/spec' }
      it { is_expected.to append_opal_path 'spec/rspec_provided' }
      it { is_expected.to_not append_opal_path 'spec' }
      it { is_expected.to require_opal_specs include('rspec_spec_fixes', 'rspec/core_spec') }
    end
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
