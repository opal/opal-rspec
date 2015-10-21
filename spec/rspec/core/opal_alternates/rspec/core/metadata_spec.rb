require 'spec_helper'

module RSpec::Core
  RSpec.describe 'Opal Metadata' do
    describe "backwards compatibility" do
      before { allow_deprecation }

      describe ":example_group" do
        it 'allows integration libraries like VCR to infer a fixture name from the example description by walking up nesting structure' do
          fixture_name_for = lambda do |metadata|
            description = metadata[:description]

            if example_group = metadata[:example_group]
              [fixture_name_for[example_group], description].join('/')
            else
              description
            end
          end

          ex = inferred_fixture_name = nil

          RSpec.configure do |config|
            config.before(:example, :infer_fixture) { |e| inferred_fixture_name = fixture_name_for[e.metadata] }
          end

          # run returns a promise
          # RSpec.describe "Group", :infer_fixture do
          #   ex = example("ex") {}
          # end.run
          #
          # raise ex.execution_result.exception if ex.execution_result.exception
          #
          # expect(inferred_fixture_name).to eq("Group/ex")

          group = RSpec.describe "Group", :infer_fixture do
            ex = example("ex") {}
          end

          group.run.then do
            raise ex.execution_result.exception if ex.execution_result.exception

            expect(inferred_fixture_name).to eq("Group/ex")
          end
        end
      end
    end
  end
end
