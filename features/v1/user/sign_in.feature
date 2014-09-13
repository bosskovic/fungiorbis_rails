Feature: Users sign in, endpoint: POST /users/sign_in
  User signs in by providing email and password.
  The response includes the authToken.
  Deactivated users can not sign in before they reactivate the user account.


  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there is a user


  Scenario: All provided fields are valid
    When I send a POST request to "/users/sign_in" with my credentials
    Then the response status should be "OK"
    And the authentication token should have changed
    And response should include user object with fields: authToken, firstName, lastName, role

  Scenario Outline: The provided login details are invalid
    When I send a POST request to "/users/sign_in" <incorrect_details>
    Then the response status should be "UNAUTHORIZED"
    And the JSON response at "errors/details" should be <error_message>
  Examples:
    | incorrect_details                          | error_message                                         |
    | with my credentials and incorrect password | ["Invalid email or password."]                        |
    | with incorrect credentials                 | ["Invalid email or password."]                        |
    | with no credentials                        | ["You need to sign in or sign up before continuing."] |


  Scenario: All provided fields are valid but my account is deactivated
    When my user account is deactivated
    And I send a POST request to "/users/sign_in" with my credentials
    Then the response status should be "UNPROCESSABLE"
    And the JSON response at "errors/details" should be ["Account deactivated. Please reactivate the account before signing in."]