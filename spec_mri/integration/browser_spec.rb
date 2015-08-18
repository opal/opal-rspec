require 'rspec'
require 'capybara/rspec'
require 'capybara-webkit'

# Use Rack config exactly as shipped in the GEM
Capybara.app = Rack::Builder.new_from_string(File.read('config.ru'))
Capybara.javascript_driver = :webkit # since Firefox is skipped right now, avoid firefox missing errors from selenium/webdriver

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
  
  context 'Webkit' do
    include_examples :browser
  end
  
  # TODO: This passes in my local tests (Firefox 40.0.2), but something in the Travis environment causes it to fail
  xcontext 'Firefox' do
    before do
      Capybara.javascript_driver = :selenium
    end   
    
    include_examples :browser
  end
end
