Feature: Users sign in, endpoint: POST /users/sign_in
  User signs in by providing email and password.
  The response includes the authToken.


  Background:
    Given I send and accept JSON
    Given there is a user


  Scenario: All provided fields are valid
    When I send a POST request to "/users/sign_in" with my credentials
    Then the response status should be "OK"
    And the authentication token should have changed
    And response should include user fields: authToken, firstName, lastName, role
    And the response should include last href


  Scenario: The provided password does not match the one stored in the db
    When I send a POST request to "/users/sign_in" with my credentials and incorrect password
    Then the response status should be "UNAUTHORIZED"
    And the JSON response at "errors" should be ["Invalid email or password."]


  Scenario: The provided email address does not exist in the db
    When I send a POST request to "/users/sign_in" with incorrect credentials
    Then the response status should be "UNAUTHORIZED"
    And the JSON response at "errors" should be ["Invalid email or password."]


  Scenario: No parameters are sent
    When I send a POST request to "/users/sign_in"
    Then the response status should be "UNAUTHORIZED"
    And the JSON response at "errors" should be ["You need to sign in or sign up before continuing."]