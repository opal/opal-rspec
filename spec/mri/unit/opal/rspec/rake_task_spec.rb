require 'rspec'
require 'opal/rspec/rake_task'
require 'rack'
require 'mri/unit/opal/rspec/temp_dir_helper'

RSpec.describe Opal::RSpec::RakeTask do
  before { Rake::Task.tasks.each(&:clear).each(&:reenable) }
  let(:runner_double) { instance_double(Opal::RSpec::Runner, command: 'echo foobar') }

  it 'forwards to Runner#command' do
    expect(Opal::RSpec::Runner).to receive(:new) { runner_double }

    task_builder = described_class.new
    expect(task_builder).to receive(:sh).with(runner_double.command)
    task_builder.rake_task.invoke
  end

  context 'with a block' do
    let(:block) { -> a,b { :foobar } }

    it 'forwards the block to Runner#command' do
      expect(Opal::RSpec::Runner).to receive(:new) do |&received_block|
        expect(received_block).to eq(block)
        runner_double
      end

      task_builder = described_class.new(&block)
      expect(task_builder).to receive(:sh).with(runner_double.command)
      task_builder.rake_task.invoke
    end
  end
end
