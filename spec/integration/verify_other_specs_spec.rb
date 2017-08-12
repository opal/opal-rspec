require 'spec_helper'

RSpec.describe 'Verify spec-opal/other' do
  describe 'dummy_spec.rb' do
    context 'using CLI' do
      it 'runs correctly' do
        test_output = `opal-rspec spec-opal/other/dummy_spec.rb 2> /dev/null`
        expect($?.exitstatus).to eq(0)
        expect(test_output).to match(/1 example, 0 failures/)
      end
    end

    context 'using Rake task' do
      it 'runs correctly' do
        test_output = `rake spec:opal PATTERN="spec-opal/other/dummy_spec.rb" 2> /dev/null`
        expect($?.exitstatus).to eq(0)
        expect(test_output).to match(/1 example, 0 failures/)
      end
    end
  end
end
