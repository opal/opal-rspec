require 'mri/spec_helper'

RSpec.describe 'Opal::RSpec::BrowserFormatter', type: :feature, js: true do
  # Use Rack config exactly as shipped in the GEM
  before { Capybara.app = Rack::Builder.new_from_string(File.read("#{__dir__}/rack/config.ru")) }

  let(:error_fetcher) { page.evaluate_script('window.jsErrors') }

  before do
    visit '/'
    # Specs should run in 12 seconds but in case Travis takes longer, provide some cushion
    Capybara.default_max_wait_time = 40
  end

  after do
    js_errors = error_fetcher
    puts "Javascript errors: #{js_errors}" if js_errors.any?
  end

  it 'matches test results' do
    expect(page).to have_content '3 examples, 1 failure, 1 pending'
    expect(page).to have_content 'group'
    expect(page).to have_content 'a skipped example'
    expect(page).to have_content 'a failed example'
  end
end
