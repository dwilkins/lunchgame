require 'devise'
require 'warden'

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, :type => :controller
  # config.include Devise::Test::ViewHelpers, :type => :view
  # config.include Devise::TestHelpers, :type => :helper

  config.include Warden::Test::Helpers
  Warden.test_mode!

  config.after(:each) { Warden.test_reset! }
end

# http://schneems.com/post/15948562424/speed-up-capybara-tests-with-devise
def as_user(user, &block)
  current_user = user

  if @request.present?
    allow(@request.env['warden']).to receive_messages(:authenticate   => current_user)
    allow(@request.env['warden']).to receive_messages(:authenticate!  => current_user)
    allow(@request.env['warden']).to receive_messages(:authenticate?  => true)

    sign_in(current_user)
  else
    login_as(current_user, :scope => :user)
  end

  block.call if block.present?
  return self
end

# http://schneems.com/post/15948562424/speed-up-capybara-tests-with-devise
def as_visitor(user=nil, &block)

  current_user = user

  request.present? ? sign_out(current_user) : logout(:user)

  block.call if block.present?
  return self
end
