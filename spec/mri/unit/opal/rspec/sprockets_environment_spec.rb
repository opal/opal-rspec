require 'rspec'
require 'opal/rspec/sprockets_environment'
require_relative 'temp_dir_helper'

describe Opal::RSpec::SprocketsEnvironment do
  include_context :temp_dir
  let(:args) { [] }
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
    
    subject do
      # in subject to allow contexts to execute before logic
      env.add_spec_paths_to_sprockets
      env.paths
    end
        
    context 'specs all 1 in path' do
      before do
        create_dummy_spec_files 'spec/foobar/dummy_spec.rb', 'spec/foobar/ignored_spec.opal'
      end
      
      let(:pattern) { 'spec/foobar/**/*_spec.rb' }
      
      it { is_expected.to have_pathnames ['spec/foobar/'] }
    end
    
    context 'multiple patterns' do
      before do
        create_dummy_spec_files 'spec/foobar/dummy_spec.rb', 'spec/foobar/ignored_spec.opal'
      end
      
      let(:pattern) { ['spec/foobar/**/*_spec.rb', 'spec/foobar/**/*_spec.opal'] }
      
      it { is_expected.to have_pathnames ['spec/foobar/'] }
    end
    
    context 'specs in different paths, same root' do
      before do
        create_dummy_spec_files 'spec/foobar/dummy_spec.rb', 'spec/noway/other_spec.rb'
      end
      
      let(:pattern) { ['spec/foobar/**/*y_spec.rb', 'spec/noway/**/*_spec.rb'] }      
      
      it { is_expected.to have_pathnames ['spec'] }
    end
    
    context 'specs in different paths, different root' do
      before do
        create_dummy_spec_files 'spec/foobar/dummy_spec.rb', 'other_path/other_spec.rb'
      end
      
      let(:pattern) { ['spec/foobar/**/*_spec.rb', 'other_path/**/*.rb'] }
      
      it { is_expected.to have_pathnames ['spec/foobar/', 'other_path/'] }
    end
    
    context 'specs in different paths, same name in middle dirs' do
      before do
        create_dummy_spec_files 'foobar/spec/something/dummy_spec.rb', 'spec/foobar/other_spec.rb'
      end
      
      let(:pattern) { ['foobar/spec/**/*_spec.rb', 'spec/foobar/other_spec.rb'] }
      
      it { is_expected.to have_pathnames ['foobar/spec/', 'spec/foobar'] }
    end
    
    context 'absolute path and relative path that are not in the same tree' do
      before do
        create_dummy_spec_files 'spec/foobar/dummy_spec.rb', 'stuff/bar/other_spec.rb'
      end
      
      let(:files) { FileList['spec/foobar/**/*_spec.rb', 'stuff/bar/other_spec.rb'] }
      let(:args) { [nil, nil, files] }    
      
      it { is_expected.to have_pathnames ['spec/foobar', 'stuff/bar'] }      
    end   
  end
end
