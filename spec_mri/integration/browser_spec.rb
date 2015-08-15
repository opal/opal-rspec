require 'rspec'
require 'capybara/rspec'
require 'capybara-webkit'
Capybara.app = Rack::Builder.new_from_string(File.read('config.ru'))

Capybara.configure do |c|
  c.javascript_driver = :webkit
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
    let(:js_errors) { page.driver.error_messages }
    include_examples :browser
  end
end
