require 'rspec'
require 'opal/rspec/rake_task'
require 'rack'
require 'opal/rspec/temp_dir_helper'

RSpec.describe Opal::RSpec::RakeTask do
  before { Rake::Task.tasks.each(&:clear).each(&:reenable) }

  it 'exits with the result of #run' do
    exitcode = 1
    runner_double = instance_double(Opal::RSpec::Runner, run: exitcode)
    task_builder = described_class.new
    expect(task_builder).to receive(:exit).with(exitcode)
    task_builder.rake_task.invoke
  end

  context 'with a block' do
    let(:runner_double) { instance_double(Opal::RSpec::Runner, run: 0) }
    let(:block) { -> a,b { :foobar } }

    xit 'forwards the block to Runner#command' do
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
