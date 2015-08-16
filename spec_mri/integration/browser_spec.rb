require 'rspec'
require 'capybara/rspec'
require 'capybara-webkit'
Capybara.app = Rack::Builder.new_from_string(File.read('config.ru'))
Capybara.register_driver :selenium do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  # see https://github.com/mguillem/JSErrorCollector
  profile.add_extension 'spec_mri/integration/JSErrorCollector.xpi'
  Capybara::Selenium::Driver.new app, :profile => profile
end

describe 'browser formatter', type: :feature, js: true do
  RSpec.shared_examples :browser do
    before do      
      visit '/'
      # specs can take some time to finish and Capybara.default_wait_time didn't seem to work right with synchronize (see below)
      sleep 20
    end
    
    it 'has test results' do
      # synchronize is needed to play nice with Selenium/Firefox
      page.document.synchronize do
        expect(page).to have_content '182 examples, 65 failures, 22 pending'
      end
    end
    
    it 'has expected JS errors' do
      expect(js_errors).to be_empty
    end    
  end
  
  context 'Webkit' do
    before do
      Capybara.javascript_driver = :webkit
    end
    
    let(:js_errors) { page.driver.error_messages }
    
    include_examples :browser
  end
  
  context 'Firefox' do
    before do
      Capybara.javascript_driver = :selenium
    end
        
    let(:js_errors) do
      raw = page.execute_script 'return window.JSErrorCollector_errors.pump()'
      # Noise
      raw.reject {|e| e['errorMessage'] == 'SyntaxError: unreachable code after return statement'}
    end
    
    include_examples :browser
  end
end
