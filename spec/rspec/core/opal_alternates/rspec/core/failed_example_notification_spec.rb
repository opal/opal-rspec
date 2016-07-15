require "spec_helper"

module RSpec::Core::Notifications
  RSpec.describe 'Opal FailedExampleNotification' do
    before do
      allow(RSpec.configuration).to receive(:color_enabled?).and_return(true)
    end

    it "uses the default color for the shared example backtrace line" do
      example = nil
      group = RSpec.describe "testing" do
        shared_examples_for "a" do
          example = it "fails" do
            expect(1).to eq(2)
          end
        end
        it_behaves_like "a"
      end
      group.run
      fne = FailedExampleNotification.new(example)
      lines = fne.colorized_message_lines
      #expect(lines).to include(match("\\e\\[37mShared Example Group:"))
      # Javascript console code
      matcher = /.*Shared Example Group.*/
      line = lines.find { |l| matcher.match l }
      escape = "\033"
      # Have to string concat this for it to work properly
      expect(line).to eq(escape +"[31m" + escape+"[37mShared Example Group: \"a\" called from "+escape+"[0m"+escape+"[0m")
    end
  end
end
