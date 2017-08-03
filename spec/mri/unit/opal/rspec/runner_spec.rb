require 'mri/spec_helper'
require 'rspec'
require 'opal/rspec/runner'
require 'mri/unit/opal/rspec/temp_dir_helper'

RSpec.describe Opal::RSpec::Runner do
  include_context :temp_dir

  # Keep ENV['RUNNER'] clean (in case we're running on travis, etc.)
  around do |example|
    current_env_runner = ENV['RUNNER']
    ENV['RUNNER'] = nil
    example.run
    ENV['RUNNER'] = current_env_runner
  end


#   let(:captured_opal_server) { {} }
#
#   RSpec::Matchers.define :invoke_runner do |expected, timeout_value=nil|
#     match do
#       invoked_runners == [
#         { type: expected, timeout_value: timeout_value }
#       ]
#     end
#   end
#
#   RSpec::Matchers.define :enable_arity_checking do
#     match do
#       Opal::Config.arity_check_enabled == true
#     end
#   end
#
  RSpec::Matchers.define :require_opal_specs do |*expected_paths|
    expected_string = nil
    match do |actual|
      expected_paths.each do |expected_path|
        expected_string = " -r#{expected_path}"
        expect(actual.command).to include(expected_string)
      end
    end

    failure_message do |actual|
      "expected #{actual.command.inspect} to include #{expected_string.inspect}"
    end
  end

  RSpec::Matchers.define :append_opal_path do |expected_path|
    expected_string = " -r#{expected_path}"
    match do |actual|
      expect(actual.command).to include(expected_string)
      # actual.command.include? " -I#{expected_path} "
    end

    failure_message do |actual|
      "expected #{actual.command.inspect} to include #{expected_string.inspect}"
    end
  end

#   let(:invoked_runners) { [] }
#   let(:task_name) { :foobar }
#   let(:expected_to_run) { true }
#
  context 'default options' do
    before { create_dummy_spec_files 'spec/something/dummy_spec.rb' }
    let(:command) { subject.command }

    it 'has default options' do
      expect(command).not_to include(' -R')
      expect(command).not_to include(' --runner')
      expect(command).to include(" -I#{temp_dir}/spec ")
      expect(subject).to require_opal_specs("#{temp_dir}/spec/something/dummy_spec.rb")
    end
  end

  context 'explicit runner' do
    before { create_dummy_spec_files 'spec/something/dummy_spec.rb' }

    RSpec.shared_context :explicit do |expected_runner|
      # it { is_expected.to have_attributes pattern: nil }
      # it { is_expected.to append_opal_path 'spec' }
      # it { is_expected.to require_opal_specs eq ['something/dummy_spec'] }
      # it { is_expected.to invoke_runner expected_runner }
      it 'sets the runner' do
        expect(subject.command).to include(" --runner #{expected_runner} ")
      end
    end

    TEST_RUNNERS = [:phantom, :node]

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
    subject { described_class.new { |_, task| task.pattern = 'spec/other/**/*_spec.rb' } }
    before { create_dummy_spec_files 'spec/other/foo_spec.rb', 'spec/other/bar_spec.rb', 'spec/other/test_formatter.rb' }

    it { expect(subject.command).to include("spec/other/foo_spec.rb") }
    it { expect(subject.command).to include("spec/other/bar_spec.rb") }
    it { expect(subject.command).not_to include("spec/other/test_formatter.rb") }
    it { expect(subject.command).not_to include("spec/other/color_on_by_default_spec.rb") }
    it { expect(subject.command).not_to include("spec/other/formatter_dependency.rb") }
    it { expect(subject.command).not_to include("spec/other/ignored_spec.opal") }
    it { is_expected.to append_opal_path "#{temp_dir}/spec" }
  end

  context 'default path' do
    subject { described_class.new { |_, task| task.pattern = 'spec/other/**/*_spec.rb'; task.default_path = 'spec/other' } }
    before { create_dummy_spec_files 'spec/other/foo_spec.rb', 'spec/other/bar_spec.rb', 'spec/other/test_formatter.rb' }

    it { is_expected.to append_opal_path "#{temp_dir}/spec/other" }
    it { expect(subject.command).to include("spec/other/foo_spec.rb") }
    it { expect(subject.command).to include("spec/other/bar_spec.rb") }
  end

  context 'files' do
    subject { described_class.new { |_, task| task.files = FileList['spec/other/**/*_spec.rb'] } }
    before { create_dummy_spec_files 'spec/other/dummy_spec.rb' }

    it { is_expected.to have_attributes files: FileList['spec/other/**/*_spec.rb'] }
    it { is_expected.to append_opal_path "#{temp_dir}/spec" }
    it { is_expected.to require_opal_specs "#{temp_dir}/spec/other/dummy_spec.rb" }
  end

  context 'pattern and files' do
    let(:expected_to_run) { false }
    let(:files) { FileList['spec/other/**/*_spec.rb', 'util/**/*.rb'] }
    let(:pattern) { 'spec/opal/**/*hooks_spec.rb' }
    subject { described_class.new { |_, task| task.files = files; task.pattern = pattern } }

    it 'cannot accept both files and a pattern' do
      expect { subject }.to raise_exception 'Cannot supply both a pattern and files!'
    end
  end
end
