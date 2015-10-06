describe 'Opal RSpec::Matchers::DSL::Matcher' do
  context "defined using the dsl" do
    it "raises NoMethodError for methods not in the running_example" do |example|
      RSpec::Matchers.define(:__raise_no_method_error) do
        match do |actual|
          self.a_method_not_in_the_example == "method defined in the example"
        end
      end

      # mutable strings
      #expected_msg = "RSpec::Matchers::DSL::Matcher"
      #expected_msg << " __raise_no_method_error" unless rbx?
      expected_msg = "RSpec::Matchers::DSL::Matcher" + " __raise_no_method_error"

      expect {
        expect(example).to __raise_no_method_error
      }.to raise_error(NoMethodError, /#{expected_msg}/)
    end
  end

  context "wrapping another expectation (expect(...).to eq ...)" do
    it "can use the `include` matcher from a `match` block" do
      RSpec::Matchers.define(:descend_from) do |mod|
        match do |klass|
          expect(klass.ancestors).to include(mod)
        end
      end

      expect(Fixnum).to descend_from(Object)
      expect(Fixnum).not_to descend_from(Array)

      expect {
        expect(Fixnum).to descend_from(Array)
      }.to fail_with(/expected Numeric to descend from Array/)
      # Fixnum = Numeric on Opal
      #}.to fail_with(/expected Fixnum to descend from Array/)

      expect {
        expect(Fixnum).not_to descend_from(Object)
        # Fixnum = Numeric on Opal
      }.to fail_with(/expected Numeric not to descend from Object/)
      #}.to fail_with(/expected Fixnum not to descend from Object/)
    end

    it "can use the `match` matcher from a `match` block" do
      RSpec::Matchers.define(:be_a_phone_number_string) do
        match do |string|
          # \A and \Z in JS regex
          # expect(string).to match(/\A\d{3}\-\d{3}\-\d{4}\z/)
          expect(string).to match(/^\d{3}\-\d{3}\-\d{4}$/)
        end
      end

      expect("206-123-1234").to be_a_phone_number_string
      expect("foo").not_to be_a_phone_number_string

      expect {
        expect("foo").to be_a_phone_number_string
      }.to fail_with(/expected "foo" to be a phone number string/)

      expect {
        expect("206-123-1234").not_to be_a_phone_number_string
      }.to fail_with(/expected "206-123-1234" not to be a phone number string/)
    end
  end
end
