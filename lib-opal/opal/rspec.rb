require 'js'

require 'opal/rspec/browser_early' if JS[:document]
require 'opal/rspec/pre_require_fixes'
require 'opal/rspec/requires'
require 'opal/rspec/fixes'
require 'opal/rspec/default_config'
require 'opal/rspec/browser' if JS[:document]
