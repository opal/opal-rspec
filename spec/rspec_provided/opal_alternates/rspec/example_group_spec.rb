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
  end
end
