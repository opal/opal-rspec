require 'rspec'
require 'capybara/rspec'

# Use Rack config exactly as shipped in the GEM
Capybara.app = Rack::Builder.new_from_string(File.read('config.ru'))

describe 'browser formatter', type: :feature do
  RSpec.shared_examples :browser do |driver, error_fetcher|
    context "in #{driver}", driver: driver do
      before do
        visit '/'
        # Specs should run in 12 seconds but in case Travis takes longer, provide some cushion
        Capybara.default_max_wait_time = 40
      end

      after do
        js_errors = error_fetcher[page]
        puts "Javascript errors: #{js_errors}" if js_errors.any?
      end

      it 'matches test results' do
        expect(page).to have_content '142 examples, 40 failures, 12 pending'
      end
    end
  end

  include_examples :browser, :selenium, lambda {|page| page.evaluate_script('window.jsErrors') }
end
