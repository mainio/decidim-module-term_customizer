# frozen_string_literal: true

require "selenium-webdriver"

module Decidim
  # This is being added because of the issues with the chrome-driver
  # in version 120 or later, and this can be removed after this pr#12160
  # being merged(more info https://github.com/decidim/decidim/pull/12159).
  Capybara.register_driver :headless_chrome do |app|
    options = ::Selenium::WebDriver::Chrome::Options.new
    options.args << "--headless=new"
    options.args << "--no-sandbox"
    options.args << if ENV["BIG_SCREEN_SIZE"].present?
                      "--window-size=1920,3000"
                    else
                      "--window-size=1920,1080"
                    end
    options.args << "--ignore-certificate-errors" if ENV["TEST_SSL"]
    Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      capabilities: [options]
    )
  end
end
