require 'spec_helper'

RSpec.describe 'browser formatter', type: :feature do
  before do
    file = "#{__dir__}/browser_spec.ru"
    Capybara.app = Rack::Builder.new_from_string(File.read(file), file)
  end

  before do
    visit '/'
    # Specs should run in 12 seconds but in case Travis takes longer, provide some cushion
    Capybara.default_max_wait_time = 40
  end

  after do
    js_errors = page.evaluate_script('window.jsErrors') || []
    puts "Javascript errors: #{js_errors}" if js_errors.any?
  end

  xit 'matches test results' do
    expect(page.find('h1')).to have_content 'RSpec Code Examples'
    expect(page.find('#totals')).to have_content '142 examples, 40 failures, 12 pending'
  end
end
