require 'capybara/rspec'

# PHANTOMJS
require 'capybara/poltergeist'
PoltergeistConsole = StringIO.new
RSpec.configure { |config| config.before { PoltergeistConsole.reopen } }
Capybara.register_driver(:poltergeist) { |app| Capybara::Poltergeist::Driver.new(app, phantomjs_logger: PoltergeistConsole) }
Capybara.default_driver = :poltergeist
Capybara.javascript_driver = :poltergeist

# SAFARI
# Capybara.register_driver(:safari) { |app| Capybara::Selenium::Driver.new(app, browser: :safari) }
# Capybara.javascript_driver = :safari

