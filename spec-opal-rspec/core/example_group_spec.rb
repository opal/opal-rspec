# encoding: utf-8
# await: *await*
require 'spec_helper'

module RSpec::Core
  RSpec.describe 'Opal ExampleGroup' do
    describe "constant naming" do
      around do |ex|
        before_constants = RSpec::ExampleGroups.constants
        ex.run
        after_constants = RSpec::ExampleGroups.constants

        (after_constants - before_constants).each do |name|
          RSpec::ExampleGroups.send(:remove_const, name)
        end
      end

      it 'disambiguates name collisions by appending a number', :unless => RUBY_VERSION == '1.9.2' do
        groups = 10.times.map { ExampleGroup.describe("Collision") }
        expect(groups[0]).to have_class_const("Collision")
        expect(groups[1]).to have_class_const("Collision_2")
        expect(groups[8]).to have_class_const("Collision_9")

        if RUBY_VERSION.to_f > 1.8 && !(defined?(RUBY_ENGINE) && ['rbx', 'opal'].include?(RUBY_ENGINE))
          # on 1.8.7, rbx "Collision_9".next => "Collisioo_0"
          expect(groups[9]).to have_class_const("Collision_10")
        end
      end
    end

    describe "#before, after, and around hooks" do
      it "treats an error in before(:each) as a failure" do
        group = ExampleGroup.describe
        group.before(:each) { raise "error in before each" }
        example = group.example("equality") { expect(1).to eq(2) }
        #expect(group.run).to be(false)
        expect(group.run).to be_a PromiseV2
        expect(group.run_await).to be_falsey

        expect(example.execution_result.exception.message).to eq("error in before each")
      end

      it "treats an error in before(:all) as a failure" do
        group = ExampleGroup.describe
        group.before(:all) { raise "error in before all" }
        example = group.example("equality") { expect(1).to eq(2) }
        #expect(group.run).to be_falsey
        expect(group.run).to be_a PromiseV2
        expect(group.run_await).to be_falsey

        expect(example.metadata).not_to be_nil
        expect(example.execution_result.exception).not_to be_nil
        expect(example.execution_result.exception.message).to eq("error in before all")
      end
    end

    describe "#run_examples" do
      let(:reporter) { double("reporter").as_null_object }

      it "returns false if any of the examples fail" do
        group = ExampleGroup.describe('group') do
          example('ex 1') { expect(1).to eq(1) }
          example('ex 2') { expect(1).to eq(2) }
        end
        allow(group).to receive(:filtered_examples) { group.examples }
        # expect(group.run(reporter)).to be_falsey
        # Promise
        result = group.run(reporter)
        expect(group.run(reporter).value).to be_falsey
      end

      it "runs all examples, regardless of any of them failing" do
        group = ExampleGroup.describe('group') do
          example('ex 1') { expect(1).to eq(2) }
          example('ex 2') { expect(1).to eq(1) }
        end
        allow(group).to receive(:filtered_examples) { group.examples }
        group.filtered_examples.each do |example|
          expect(example).to receive(:run)
        end
        # expect(group.run(reporter)).to be_falsey
        # Promise
        expect(group.run(reporter).value).to be_falsey
      end
    end

    describe "#run" do
      let(:reporter) { double("reporter").as_null_object }

      context "with fail_fast? => true" do
        let(:group) do
          group = RSpec::Core::ExampleGroup.describe
          allow(group).to receive(:fail_fast?) { true }
          group
        end

        it "sets RSpec.world.wants_to_quit flag if encountering an exception in before(:all)" do
          group.before(:all) { raise "error in before all" }
          group.example("equality") { expect(1).to eq(2) }
          # This method returns a promise in Opal
          #expect(group.run).to be_falsey
          expect(group.run.value).to be_falsey
          expect(RSpec.world.wants_to_quit).to be_truthy
        end
      end

      context "with top level example failing" do
        it "returns false" do
          group = RSpec::Core::ExampleGroup.describe("something") do
            it "does something (wrong - fail)" do
              raise "fail"
            end
            describe "nested" do
              it "does something else" do
                # pass
              end
            end
          end

          #expect(group.run(reporter)).to be_falsey
          # Promise
          expect(group.run(reporter).value).to be_falsey
        end
      end

      context "with nested example failing" do
        it "returns true" do
          group = RSpec::Core::ExampleGroup.describe("something") do
            it "does something" do
              # pass
            end
            describe "nested" do
              it "does something else (wrong -fail)" do
                raise "fail"
              end
            end
          end

          #expect(group.run(reporter)).to be_falsey
          # Promise
          expect(group.run(reporter).value).to be_falsey
        end
      end
    end
  end
end
