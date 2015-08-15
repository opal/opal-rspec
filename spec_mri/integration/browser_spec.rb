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
    end
    
    it 'has test results' do
      expect(page).to have_content 'foobar'
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
        
    let(:js_errors) { page.execute_script("return window.JSErrorCollector_errors.pump()") }
    include_examples :browser
  end
end
