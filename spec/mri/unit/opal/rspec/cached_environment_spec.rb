require 'rspec'
require 'opal/rspec/cached_environment'
require 'opal/rspec/sprockets_environment'

describe Opal::RSpec::CachedEnvironment do
  let(:pattern) { nil }
  let(:exclude_pattern) { nil }
  let(:files) { nil }
  
  let(:original_env) { Opal::RSpec::SprocketsEnvironment.new pattern, exclude_pattern, files }
  
  before do
    original_env.add_spec_paths_to_sprockets
  end
  
  subject(:env) { original_env.cached }
  
  describe '#get_opal_spec_requires' do
    subject { env.get_opal_spec_requires }
    
    context '1 path' do
      let(:pattern) { 'spec/other/**/*_spec.rb' }
      
      it { is_expected.to eq ['dummy_spec'] }
    end
    
    context '2 paths, same root' do    
      let(:pattern) { ['spec/opal/**/*hooks_spec.rb', 'spec/other/**/*_spec.rb'] }
      
      it { is_expected.to eq ['opal/after_hooks_spec', 'opal/around_hooks_spec', 'opal/before_hooks_spec', 'other/dummy_spec'] }
    end
    
    context '2 paths, different root' do
      let(:pattern) { ['spec/other/**/*_spec.rb', 'util/**/*.rb'] }
      
      it { is_expected.to eq ['dummy_spec', 'create_requires'] }
    end    
    
    context 'specs in different paths, same name in middle dirs' do
      let(:pattern) { ['rspec-core/spec/**/*_spec.rb', 'spec/rspec_provided/rspec_spec_fixes.rb'] }
      
      it { is_expected.to include('rspec_spec_fixes', 'rspec/core_spec') }
    end
    
    context 'absolute path and relative path that are not in the same tree' do
      let(:tmp_spec_dir) { Dir.mktmpdir }
      
      let(:dummy_spec) do
        fake_spec = File.join tmp_spec_dir, 'junk_spec.rb'
        FileUtils.touch fake_spec
        fake_spec
      end
      
      let(:files) { FileList['spec/other/**/*_spec.rb', dummy_spec] }
      
      after do
        FileUtils.remove_entry tmp_spec_dir
      end      
      
      it { is_expected.to eq ['dummy_spec', 'junk_spec'] }
    end
    
    context 'exclude pattern' do
      let(:pattern) { 'spec/**/*_spec.rb' }
      
      context 'single' do        
        let(:exclude_pattern) { '**/*/*_hooks_spec.rb' }
        
        it { is_expected.to include 'mri/integration/browser_spec' }
        it { is_expected.to include 'opal/async_spec' }
        it { is_expected.to_not include('opal/after_hooks_spec', 'opal/around_hooks_spec') }
      end
      
      context 'multiple' do      
        let(:exclude_pattern) { ['**/*/*_hooks_spec.rb', '**/*/a*_spec.rb'] }
        
        it { is_expected.to include 'mri/integration/browser_spec' }
        it { is_expected.to_not include 'opal/async_spec' }
        it { is_expected.to_not include('opal/after_hooks_spec', 'opal/around_hooks_spec') }
      end
    end
    
    context 'files' do
      let(:files) { FileList['spec/other/**/*_spec.rb'] }
      
      it { is_expected.to eq ['dummy_spec'] }
    end
  end  
end
