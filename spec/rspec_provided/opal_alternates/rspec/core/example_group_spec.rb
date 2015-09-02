# encoding: utf-8
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
        expect(group.run).to be_a Promise
        expect(group.run.value).to be_falsey

        expect(example.execution_result.exception.message).to eq("error in before each")
      end

      it "treats an error in before(:all) as a failure" do
        group = ExampleGroup.describe
        group.before(:all) { raise "error in before all" }
        example = group.example("equality") { expect(1).to eq(2) }
        #expect(group.run).to be_falsey
        expect(group.run).to be_a Promise
        expect(group.run.value).to be_falsey

        expect(example.metadata).not_to be_nil
        expect(example.execution_result.exception).not_to be_nil
        expect(example.execution_result.exception.message).to eq("error in before all")
      end
    end
  end
end
