require 'shellwords'
require 'spec_helper'
require 'rspec'
require 'opal/rspec/runner'
require 'opal/rspec/temp_dir_helper'

RSpec.describe Opal::RSpec::Runner do
  include_context :temp_dir

  # Keep ENV['RUNNER'] clean (in case we're running on travis, etc.)
  around do |example|
    current_env_runner = ENV['RUNNER']
    ENV['RUNNER'] = nil
    example.run
    ENV['RUNNER'] = current_env_runner
  end

  RSpec::Matchers.define :invoke_runner do |expected, timeout_value=nil|
    expected_string = " --runner #{expected} "
    match do |actual|
      expect(actual.command+' ').to include(expected_string)
    end

    failure_message do |actual|
      "expected #{actual.command.inspect} to include #{expected_string.inspect}"
    end
  end

  RSpec::Matchers.define :require_opal_specs do |*expected_paths|
    expected_string = nil
    match do |actual|
      expected_paths.each do |expected_path|
        expected_string = " -p#{expected_path}"
        expect(actual.command).to include(expected_string)
      end
    end

    failure_message do |actual|
      "expected #{actual.command.inspect} to include #{expected_string.inspect}"
    end
  end

  RSpec::Matchers.define :append_opal_path do |expected_path|
    expected_string = " -I#{expected_path} "
    match do |actual|
      expect(actual.command+' ').to include(expected_string)
    end

    failure_message do |actual|
      "expected #{actual.command.inspect} to include #{expected_string.inspect}"
    end
  end

  context 'default options' do
    before { create_dummy_spec_files 'spec-opal/something/dummy_spec.rb' }
    let(:command) { subject.command }

    it 'has default options' do
      expect(command).not_to include(' -R')
      expect(command).not_to include(' --runner')
      expect(command).to include(" -I#{temp_dir}/spec-opal ")
      expect(subject).to require_opal_specs("#{temp_dir}/spec-opal/something/dummy_spec.rb")
    end
  end

  context 'explicit runner' do
    before { create_dummy_spec_files 'spec-opal/something/dummy_spec.rb' }

    RSpec.shared_context :explicit do |expected_runner|
      it 'sets the options' do
        expect(subject).to have_attributes pattern: nil
        expect(subject).to append_opal_path "#{temp_dir}/spec-opal"
        expect(subject).to require_opal_specs("#{temp_dir}/spec-opal/something/dummy_spec")
        expect(subject).to invoke_runner expected_runner
      end
    end

    TEST_RUNNERS = [:chrome, :node, :server]

    context 'setting runner via ENV' do
      TEST_RUNNERS.each do |runner|
        context "as #{runner}" do
          before do
            ENV['RUNNER'] = runner.to_s
          end
          subject { described_class.new }

          include_context :explicit, runner
        end
      end
    end

    context 'Rake task' do
      TEST_RUNNERS.each do |runner|
        context "as #{runner}" do
          subject do
            described_class.new do |_, runner_|
              runner_.runner = runner
            end
          end

          include_context :explicit, runner
        end
      end
    end
  end

  context 'pattern' do
    subject { described_class.new { |_, task| task.pattern = 'spec-opal/other/**/*_spec.rb' } }
    before { create_dummy_spec_files 'spec-opal/other/foo_spec.rb', 'spec-opal/other/bar_spec.rb', 'spec-opal/other/test_formatter.rb' }

    it { expect(subject.command).to include("spec-opal/other/foo_spec.rb") }
    it { expect(subject.command).to include("spec-opal/other/bar_spec.rb") }
    it { expect(subject.command).not_to include("spec-opal/other/test_formatter.rb") }
    it { expect(subject.command).not_to include("spec-opal/other/color_on_by_default_spec.rb") }
    it { expect(subject.command).not_to include("spec-opal/other/formatter_dependency.rb") }
    it { expect(subject.command).not_to include("spec-opal/other/ignored_spec.opal") }
    it { is_expected.to append_opal_path "#{temp_dir}/spec-opal" }
  end

  context 'default path' do
    subject { described_class.new { |_, task| task.pattern = 'spec-opal/other/**/*_spec.rb'; task.default_path = 'spec-opal/other' } }
    before { create_dummy_spec_files 'spec-opal/other/foo_spec.rb', 'spec-opal/other/bar_spec.rb', 'spec-opal/other/test_formatter.rb' }

    it { is_expected.to append_opal_path "#{temp_dir}/spec-opal/other" }
    it { expect(subject.command).to include("spec-opal/other/foo_spec.rb") }
    it { expect(subject.command).to include("spec-opal/other/bar_spec.rb") }
  end

  context 'files' do
    subject { described_class.new { |_, task| task.files = FileList['spec-opal/other/**/*_spec.rb'] } }
    before { create_dummy_spec_files 'spec-opal/other/dummy_spec.rb' }

    it { is_expected.to have_attributes files: FileList['spec-opal/other/**/*_spec.rb'] }
    it { is_expected.to append_opal_path "#{temp_dir}/spec-opal" }
    it { is_expected.to require_opal_specs "#{temp_dir}/spec-opal/other/dummy_spec.rb" }
  end

  context 'pattern and files' do
    before { create_dummy_spec_files 'spec-opal/spec_spec.rb' }

    let(:expected_to_run) { false }
    let(:files) { FileList['spec-opal/*_spec.rb'] }
    let(:pattern) { 'spec-opal/**/*spec_spec.rb' }
    subject { described_class.new { |_, task| task.files = files; task.pattern = pattern } }

    it 'cannot accept both files and a pattern' do
      expect { subject }.to raise_exception 'Cannot supply both a pattern and files!'
    end
  end
end
