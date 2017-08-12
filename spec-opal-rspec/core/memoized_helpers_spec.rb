require 'spec_helper'

module RSpec::Core
  RSpec.describe 'Opal MemoizedHelpers' do
    before(:each) { RSpec.configuration.configure_expectation_framework }

    context "using 'self' as an explicit subject" do
      it "delegates matcher to the ExampleGroup" do
        group = ExampleGroup.describe("group") do
          subject { self }
          def ok?; true; end
          def not_ok?; false; end

          it { is_expected.to eq(self) }
          it { is_expected.to be_ok }
          it { is_expected.to_not be_not_ok }
        end

        #expect(group.run).to be true
        expect(group.run).to be_a Promise
        expect(group.run.value).to be_truthy
      end

      it 'supports a new expect-based syntax' do
        group = ExampleGroup.describe([1, 2, 3]) do
          it { is_expected.to be_an Array }
          it { is_expected.not_to include 4 }
        end

        #expect(group.run).to be true
        expect(group.run).to be_a Promise
        expect(group.run.value).to be_truthy
      end
    end
  end
end
