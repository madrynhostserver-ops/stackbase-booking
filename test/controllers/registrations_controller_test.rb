require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "visitor can create an account" do
    assert_difference("User.count", 1) do
      post registration_url, params: {
        user: {
          email: "new-user@example.com",
          password: "Password123!",
          password_confirmation: "Password123!",
        },
      }
    end

    assert_redirected_to root_url
  end
end
