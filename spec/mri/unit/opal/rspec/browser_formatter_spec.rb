require 'rspec'
require 'capybara/rspec'

# Use Rack config exactly as shipped in the GEM
rack_path = File.join(File.dirname(__FILE__), 'rack/config.ru')
Capybara.app = Rack::Builder.new_from_string(File.read(rack_path))

describe 'Opal::RSpec::BrowserFormatter', type: :feature do
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
        expect(page).to have_content '3 examples, 1 failure, 1 pending'
        expect(page).to have_content 'group'
        expect(page).to have_content 'a skipped example'
        expect(page).to have_content 'a failed example'
      end
    end
  end

  include_examples :browser, :selenium, lambda {|page| page.evaluate_script('window.jsErrors') }
end
