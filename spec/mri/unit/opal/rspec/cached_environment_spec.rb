require 'rspec'
require 'opal/rspec/cached_environment'
require 'opal/rspec/sprockets_environment'
require_relative 'temp_dir_helper'

describe Opal::RSpec::CachedEnvironment do
  let(:pattern) { nil }
  let(:exclude_pattern) { nil }
  let(:files) { nil }
  include_context :temp_dir

  let(:original_env) { Opal::RSpec::SprocketsEnvironment.new pattern, exclude_pattern, files }

  subject(:env) do
    # in subject to allow contexts to execute before logic
    original_env.add_spec_paths_to_sprockets
    original_env.cached
  end

  describe '#get_opal_spec_requires' do
    subject { env.get_opal_spec_requires.sort }

    context '1 path' do
      before do
        create_dummy_spec_files 'spec/foobar/dummy_spec.rb', 'spec/foobar/ignored_spec.opal'
      end

      let(:pattern) { 'spec/foobar/**/*_spec.rb' }

      it { is_expected.to eq ['dummy_spec'] }
    end

    context '2 paths, same root' do
      before do
        create_dummy_spec_files 'spec/foobar/dummy_spec.rb', 'spec/noway/other_spec.rb'
      end

      let(:pattern) { ['spec/foobar/**/*y_spec.rb', 'spec/noway/**/*_spec.rb'] }

      it { is_expected.to eq ['foobar/dummy_spec', 'noway/other_spec'] }
    end

    context '2 paths, different root' do
      before do
        create_dummy_spec_files 'spec/foobar/dummy_spec.rb', 'other_path/other_spec.rb'
      end

      let(:pattern) { ['spec/foobar/**/*_spec.rb', 'other_path/**/*.rb'] }

      it { is_expected.to eq ['dummy_spec', 'other_spec'] }
    end

    context 'specs in different paths, same name in middle dirs' do
      before do
        create_dummy_spec_files 'foobar/spec/something/dummy_spec.rb', 'spec/foobar/other_spec.rb'
      end

      let(:pattern) { ['foobar/spec/**/*_spec.rb', 'spec/foobar/other_spec.rb'] }

      it { is_expected.to eq ['other_spec', 'something/dummy_spec'] }
    end

    context 'absolute path and relative path that are not in the same tree' do
      before do
        create_dummy_spec_files 'spec/foobar/dummy_spec.rb', 'stuff/bar/other_spec.rb'
      end

      let(:files) { FileList['spec/foobar/**/*_spec.rb', 'stuff/bar/other_spec.rb'] }

      it { is_expected.to eq ['dummy_spec', 'other_spec'] }
    end

    context 'exclude pattern' do
      before do
        create_dummy_spec_files 'spec/foobar/hello1_spec.rb', 'spec/foobar/hello2_spec.rb', 'spec/foobar/bye1_spec.rb', 'spec/foobar/bye2_spec.rb'
      end

      let(:pattern) { 'spec/**/*_spec.rb' }

      context 'single' do
        let(:exclude_pattern) { '**/*/*1_spec.rb' }

        it { is_expected.to eq ['foobar/bye2_spec', 'foobar/hello2_spec'] }
      end

      context 'multiple' do
        let(:exclude_pattern) { ['**/*/*1_spec.rb', '**/*/bye*_spec.rb' ] }

        it { is_expected.to eq ['foobar/hello2_spec'] }
      end
    end

    context 'files' do
      before do
        create_dummy_spec_files 'spec/foobar/hello1_spec.rb', 'spec/foobar/hello2_spec.rb', 'spec/foobar/bye1_spec.rb', 'spec/foobar/bye2_spec.rb'
      end

      let(:files) { FileList['spec/**/h*_spec.rb'] }

      it { is_expected.to eq ['hello1_spec', 'hello2_spec'] }
    end
  end
end
