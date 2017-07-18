require 'capybara/rspec'

# PHANTOMJS
# require 'capybara/poltergeist'
# PoltergeistConsole = StringIO.new
# RSpec.configure { |config| config.before { PoltergeistConsole.reopen } }
# Capybara.register_driver(:poltergeist) { |app| Capybara::Poltergeist::Driver.new(app, phantomjs_logger: PoltergeistConsole) }

# SAFARI
Capybara.register_driver(:safari) { |app| Capybara::Selenium::Driver.new(app, browser: :safari) }

# CHROME
require "selenium/webdriver"
require 'chromedriver/helper'
Chromedriver.set_version "2.30"
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(chromeOptions: { args: %w(headless disable-gpu) })
  Capybara::Selenium::Driver.new app, browser: :chrome, desired_capabilities: capabilities
end




# Capybara.default_driver = :poltergeist
# Capybara.javascript_driver = :poltergeist
# Capybara.default_driver = :safari
# Capybara.javascript_driver = :safari
Capybara.javascript_driver = :headless_chrome
Capybara.default_driver = :headless_chrome
# Capybara.javascript_driver = :chrome
# Capybara.default_driver = :chrome


