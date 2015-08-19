require 'rspec'
require 'capybara/rspec'
require 'capybara-webkit'

# Use Rack config exactly as shipped in the GEM
Capybara.app = Rack::Builder.new_from_string(File.read('config.ru'))

describe 'browser formatter', type: :feature, js: true do
  RSpec.shared_examples :browser do
    before do
      visit '/'
      # Specs should run in 12 seconds but in case Travis takes longer, provide some cushion
      Capybara.default_wait_time = 40
    end
    
    it 'matches test results' do
      expect(page).to have_content '182 examples, 65 failures, 22 pending'
    end    
  end
  
  xcontext 'Webkit' do
    before do
      Capybara.javascript_driver = :webkit
    end
    
    include_examples :browser
    
    after do
      puts "Javascript errors: #{page.driver.error_messages}"
    end
  end
  
  context 'Firefox' do
    before do
      Capybara.javascript_driver = :selenium
    end   
    
    include_examples :browser
  end
end
