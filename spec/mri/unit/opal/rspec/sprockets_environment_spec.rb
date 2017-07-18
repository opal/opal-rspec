require 'rspec'
require 'opal/rspec/sprockets_environment'
require 'mri/unit/opal/rspec/temp_dir_helper'

RSpec.describe Opal::RSpec::SprocketsEnvironment do
  include_context :temp_dir
  let(:args) { [] }
  subject(:env) { Opal::RSpec::SprocketsEnvironment.new *args }

  RSpec::Matchers.define :have_pathnames do |expected|
    expected = expected.map { |p| File.expand_path(p) }

    match do |actual|
      actual == expected
    end
  end

  describe '#cached' do
    subject { env.cached }

    it { is_expected.to be_a ::Opal::RSpec::CachedEnvironment }
  end

  describe '#add_spec_paths_to_sprockets' do
    let(:args) { [pattern, nil, nil, default_path] }
    let(:default_path) { nil }

    subject do
      # in subject to allow contexts to execute before logic
      env.add_spec_paths_to_sprockets
      env.paths.sort
    end

    context 'default path not set' do
      before do
        create_dummy_spec_files 'spec/foobar/dummy_spec.rb', 'spec/foobar/ignored_spec.opal'
      end

      let(:pattern) { 'spec/foobar/**/*_spec.rb' }

      it { is_expected.to have_pathnames ['spec'] }
    end

    context 'default path set' do
      before do
        create_dummy_spec_files 'spec/foobar/dummy_spec.rb', 'spec/foobar/ignored_spec.opal'
      end

      let(:pattern) { 'spec/foobar/**/*_spec.rb' }
      let(:default_path) { 'spec/foobar' }

      it { is_expected.to have_pathnames ['spec/foobar'] }
    end
  end
end
