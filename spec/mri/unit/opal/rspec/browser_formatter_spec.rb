require 'mri/spec_helper'

RSpec.describe 'Opal::RSpec::BrowserFormatter', type: :feature, js: true do
  # Use Rack config exactly as shipped in the GEM
  before do
    file = "#{__dir__}/rack/config.ru"
    Capybara.app = Rack::Builder.new_from_string(File.read(file), file)
  end

  let(:error_fetcher) { page.evaluate_script('window.jsErrors') }

  before do
    visit '/'
    # Specs should run in 12 seconds but in case Travis takes longer, provide some cushion
    Capybara.default_max_wait_time = 40
  end

  it 'matches test results' do
    expect(page).to have_content '3 examples, 1 failure, 1 pending'
    expect(page).to have_content 'group'
    expect(page).to have_content 'a skipped example'
    expect(page).to have_content 'a failed example'
  end
end
