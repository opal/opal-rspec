require 'rspec'
require 'opal/rspec/sprockets_environment'

describe Opal::RSpec::SprocketsEnvironment do
  let(:args) { [] }
  let(:pattern_with_some_specs) { 'spec/other/**/*_spec.rb' }
  let(:different_directory_specs) { 'spec/opal/**/*_spec.rb' }
  subject(:env) { Opal::RSpec::SprocketsEnvironment.new *args }
  
  RSpec::Matchers.define :have_opal_spec_path do |expected|
    def actual(env)
      env.get_opal_spec_paths
    end
    
    match_when_negated do |env|
      actual(env) != expected
    end
    
    failure_message_when_negated do |env|
      "Expected opal spec paths to not match #{expected}, but they did. Example: #{actual(env)}"
    end
  end
  
  describe '#spec_pattern=' do
    let(:args) { [pattern_with_some_specs] }
    
    before do
      @original_spec_path = env.get_opal_spec_paths
      env.spec_pattern = different_directory_specs
    end
    
    it { is_expected.to have_attributes spec_pattern: different_directory_specs }
    it { is_expected.to_not have_opal_spec_path @original_spec_path }
  end  
  
  describe '#spec_files=' do
    let(:files) { FileList[pattern_with_some_specs] }
    let(:different_files) { FileList[different_directory_specs] }
    let(:args) { [nil, nil, files] }
    
    before do
      @original_spec_path = env.get_opal_spec_paths
      env.spec_files = different_files
    end
    
    it { is_expected.to have_attributes spec_files: different_files }
    it { is_expected.to_not have_opal_spec_path @original_spec_path }
  end
  
  describe '#cached' do
    subject { env.cached }
    
    it { is_expected.to be_a ::Opal::RSpec::CachedEnvironment }
  end
  
  describe '#get_opal_spec_paths' do
    subject { env.get_opal_spec_paths.map {|p| p.to_s} }
    let(:args) { [pattern] }
    
    context 'specs all 1 in path' do
      let(:pattern) { 'spec/opal/**/*_spec.rb' }
      
      it { is_expected.to eq ['spec/opal/'] }
    end
    
    context 'multiple patterns' do
      let(:pattern) { ['spec/opal/**/*hooks_spec.rb', 'spec/opal/**/matchers_spec.rb'] }
      
      it { is_expected.to eq ['spec/opal/'] }
    end
    
    context 'specs in different paths, same root' do
      let(:pattern) { ['spec/opal/**/*hooks_spec.rb', 'spec/other/**/*_spec.rb'] }
      
      it { is_expected.to eq ['spec'] }
    end
    
    context 'specs in different paths, different root' do
      let(:pattern) { ['spec/other/**/*_spec.rb', 'util/**/*.rb'] }
      
      it { is_expected.to eq ['spec/other/', 'util/'] }
    end
    
    context 'specs in different paths, same name in middle dirs' do
      let(:pattern) { ['rspec-core/spec/**/*_spec.rb', 'spec/rspec_provided/rspec_spec_fixes.rb'] }
      
      it { is_expected.to eq ['rspec-core/spec/', 'spec/rspec_provided'] }
    end 
  end
end
