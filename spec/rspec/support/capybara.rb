require "capybara/rspec"
require "capybara/apparition"

Capybara.register_driver :apparition_opal do |app|
  Capybara::Apparition::Driver.new(app,
    browser_options: { 'no-sandbox' => true }
  )
end

Capybara.javascript_driver = :apparition_opal
Capybara.default_driver = :apparition_opal
