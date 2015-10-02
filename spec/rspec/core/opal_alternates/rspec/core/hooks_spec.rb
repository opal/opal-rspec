require "spec_helper"

module RSpec::Core
  RSpec.describe 'Opal RSpec::Core::Hooks' do
    context "when an error happens in `after(:suite)`" do
      it 'allows the error to propagate to the user' do
        RSpec.configuration.after(:suite) { 1 / 0 }

        # expect {
        #   RSpec.configuration.hooks.run(:after, :suite, SuiteHookContext.new)
        # }.to raise_error(ZeroDivisionError)
        # hooks returns a promise, have to wait for that
        RSpec.configuration.hooks.run(:after, :suite, SuiteHookContext.new).then do
          raise 'Expected ZeroDivisionError but got none'
        end.rescue do |ex|
          expect(ex).to be_a? ZeroDivisionError
        end
      end
    end

    context "when an error happens in `before(:suite)`" do
      it 'allows the error to propagate to the user' do
        RSpec.configuration.before(:suite) { 1 / 0 }

        # expect {
        #   RSpec.configuration.hooks.run(:before, :suite, SuiteHookContext.new)
        # }.to raise_error(ZeroDivisionError)
        # hooks return a promise
        RSpec.configuration.hooks.run(:before, :suite, SuiteHookContext.new).then do
          raise 'Expected ZeroDivisionError but got none'
        end.rescue do |ex|
          expect(ex).to be_a? ZeroDivisionError
        end
      end
    end

    describe "#around" do
      it 'considers the hook to have run when passed as a block to a method that yields' do
        ex = nil
        group = RSpec.describe do
          def transactionally
            yield
          end

          around { |e| transactionally(&e) }
          ex = example("run") {}
        end

        # promise
        # group.run
        # expect(ex.execution_result.status).to eq(:passed)
        group.run.then do
          expect(ex.execution_result.status).to eq(:passed)
        end
      end
    end
  end
end
