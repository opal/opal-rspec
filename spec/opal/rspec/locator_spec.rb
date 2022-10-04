require 'spec_helper'

RSpec.describe Opal::RSpec::Locator do
  let(:root_path) { File.expand_path("#{__dir__}/../../..") }

  context 'with default args' do
    specify '#determine_root' do
      expect(subject.determine_root.to_s).to eq(root_path)
    end

    specify '#get_spec_load_paths' do
      expect(subject.get_spec_load_paths).to eq(["#{root_path}/spec-opal"])
    end

    specify '#get_opal_spec_requires' do
      expect(subject.get_opal_spec_requires.sort).to eq([
        "#{root_path}/spec-opal/after_hooks_spec.rb",
        "#{root_path}/spec-opal/around_hooks_spec.rb",
        "#{root_path}/spec-opal/async_spec.rb",
        "#{root_path}/spec-opal/before_hooks_spec.rb",
        "#{root_path}/spec-opal/browser-formatter/opal_browser_formatter_spec.rb",
        "#{root_path}/spec-opal/example_spec.rb",
        "#{root_path}/spec-opal/matchers_spec.rb",
        "#{root_path}/spec-opal/mock_spec.rb",
        "#{root_path}/spec-opal/other/color_on_by_default_spec.rb",
        "#{root_path}/spec-opal/other/dummy_spec.rb",
        "#{root_path}/spec-opal/should_syntax_spec.rb",
        "#{root_path}/spec-opal/skip_pending_spec.rb",
        "#{root_path}/spec-opal/subject_spec.rb",
        "#{root_path}/spec-opal/other/ignored_spec.opal",
      ].sort)
    end
  end

  context 'with a set default_path' do
    subject { described_class.new(default_path: 'lib/opal') }

    specify '#determine_root' do
      expect(subject.determine_root.to_s).to eq(root_path)
    end

    specify '#get_spec_load_paths' do
      expect(subject.get_spec_load_paths).to eq(["#{root_path}/lib/opal"])
    end

    specify '#get_opal_spec_requires' do
      expect(subject.get_opal_spec_requires.sort).to eq([
        "#{root_path}/spec-opal/after_hooks_spec.rb",
        "#{root_path}/spec-opal/around_hooks_spec.rb",
        "#{root_path}/spec-opal/async_spec.rb",
        "#{root_path}/spec-opal/before_hooks_spec.rb",
        "#{root_path}/spec-opal/browser-formatter/opal_browser_formatter_spec.rb",
        "#{root_path}/spec-opal/example_spec.rb",
        "#{root_path}/spec-opal/matchers_spec.rb",
        "#{root_path}/spec-opal/mock_spec.rb",
        "#{root_path}/spec-opal/other/color_on_by_default_spec.rb",
        "#{root_path}/spec-opal/other/dummy_spec.rb",
        "#{root_path}/spec-opal/should_syntax_spec.rb",
        "#{root_path}/spec-opal/skip_pending_spec.rb",
        "#{root_path}/spec-opal/subject_spec.rb",
        "#{root_path}/spec-opal/other/ignored_spec.opal",
      ].sort)
    end
  end

  context 'with a set pattern' do
    subject { described_class.new(default_path: 'lib/opal', pattern: 'lib/opal/*.rb') }

    specify '#get_opal_spec_requires' do
      expect(subject.get_opal_spec_requires).to eq(["#{root_path}/lib/opal/rspec.rb"])
    end
  end
end
