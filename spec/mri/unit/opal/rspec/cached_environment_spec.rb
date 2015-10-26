require 'rspec'
require 'opal/rspec/cached_environment'
require 'opal/rspec/sprockets_environment'
require_relative 'temp_dir_helper'

describe Opal::RSpec::CachedEnvironment do
  let(:pattern) { nil }
  let(:exclude_pattern) { nil }
  let(:default_path) { nil }
  let(:files) { nil }
  include_context :temp_dir

  let(:original_env) { Opal::RSpec::SprocketsEnvironment.new pattern, exclude_pattern, files, default_path }

  subject(:env) do
    # in subject to allow contexts to execute before logic
    original_env.add_spec_paths_to_sprockets
    original_env.cached
  end

  describe '#get_opal_spec_requires' do
    subject { env.get_opal_spec_requires.sort }

    context 'no default path set' do
      before do
        create_dummy_spec_files 'spec/foobar/dummy_spec.rb', 'spec/foobar/ignored_spec.opal'
      end

      let(:pattern) { 'spec/foobar/**/*_spec.rb' }

      it { is_expected.to eq ['foobar/dummy_spec'] }
    end

    context 'default path set' do
      before do
        create_dummy_spec_files 'spec/foobar/dummy_spec.rb', 'spec/foobar/ignored_spec.opal'
      end

      let(:pattern) { 'spec/foobar/**/*_spec.rb' }
      let(:default_path) { 'spec/foobar' }

      it { is_expected.to eq ['dummy_spec'] }
    end

    context 'multiple pattern' do
      before do
        create_dummy_spec_files 'spec/foobar/hello1_spec.rb', 'spec/foobar/hello2_spec.rb', 'spec/foobar/bye1_spec.rb', 'spec/foobar/bye2_spec.rb'
      end

      let(:pattern) { %w(**/*/*1_spec.rb **/*/bye*_spec.rb) }

      it { is_expected.to eq %w(foobar/bye1_spec foobar/bye2_spec foobar/hello1_spec) }
    end

    context 'exclude pattern' do
      before do
        create_dummy_spec_files 'spec/foobar/hello1_spec.rb', 'spec/foobar/hello2_spec.rb', 'spec/foobar/bye1_spec.rb', 'spec/foobar/bye2_spec.rb'
      end

      let(:pattern) { 'spec/**/*_spec.rb' }

      context 'single' do
        let(:exclude_pattern) { '**/*/*1_spec.rb' }

        it { is_expected.to eq %w(foobar/bye2_spec foobar/hello2_spec) }
      end

      context 'multiple' do
        let(:exclude_pattern) { %w(**/*/*1_spec.rb **/*/bye*_spec.rb) }

        it { is_expected.to eq ['foobar/hello2_spec'] }
      end
    end

    context 'files' do
      before do
        create_dummy_spec_files 'spec/foobar/hello1_spec.rb', 'spec/foobar/hello2_spec.rb', 'spec/foobar/bye1_spec.rb', 'spec/foobar/bye2_spec.rb'
      end

      let(:files) { FileList['spec/**/h*_spec.rb'] }

      it { is_expected.to eq %w(foobar/hello1_spec foobar/hello2_spec) }
    end
  end
end
