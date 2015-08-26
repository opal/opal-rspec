require 'rspec'
require 'opal/rspec/sprockets_environment'

describe Opal::RSpec::SprocketsEnvironment do
  let(:args) { [] }
  let(:pattern_with_some_specs) { 'spec/other/**/*_spec.rb' }
  let(:different_directory_specs) { 'spec/opal/**/*_spec.rb' }
  subject(:env) { Opal::RSpec::SprocketsEnvironment.new *args }
  
  RSpec::Matchers.define :have_pathnames do |expected|
    expected = expected.map {|p| File.expand_path(p) }
    
    match do |actual|
      actual == expected
    end
  end
  
  describe '#cached' do
    subject { env.cached }
    
    it { is_expected.to be_a ::Opal::RSpec::CachedEnvironment }
  end
  
  describe '#add_spec_paths_to_sprockets' do
    let(:args) { [pattern] }
    
    subject { env.paths }
    
    before do
      env.add_spec_paths_to_sprockets
    end  
    
    context 'specs all 1 in path' do
      let(:pattern) { 'spec/opal/**/*_spec.rb' }
      
      it { is_expected.to have_pathnames ['spec/opal/'] }
    end
    
    context 'multiple patterns' do
      let(:pattern) { ['spec/opal/**/*hooks_spec.rb', 'spec/opal/**/matchers_spec.rb'] }
      
      it { is_expected.to have_pathnames ['spec/opal/'] }
    end
    
    context 'specs in different paths, same root' do
      let(:pattern) { ['spec/opal/**/*hooks_spec.rb', 'spec/other/**/*_spec.rb'] }
      
      it { is_expected.to have_pathnames ['spec'] }
    end
    
    context 'specs in different paths, different root' do
      let(:pattern) { ['spec/other/**/*_spec.rb', 'util/**/*.rb'] }
      
      it { is_expected.to have_pathnames ['spec/other/', 'util/'] }
    end
    
    context 'specs in different paths, same name in middle dirs' do
      let(:pattern) { ['rspec-core/spec/**/*_spec.rb', 'spec/rspec_provided/rspec_spec_fixes.rb'] }
      
      it { is_expected.to have_pathnames ['rspec-core/spec/', 'spec/rspec_provided'] }
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

      let(:args) { [nil, nil, files] }    
      
      it { is_expected.to have_pathnames ['spec/other', tmp_spec_dir] }      
    end   
  end
end
