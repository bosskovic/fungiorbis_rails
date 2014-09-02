Feature: Users sign out, endpoint: DELETE /users/sign_out
  The request with the proper authentication headers to this endpoint causes the user's authToken to be reset.
  The response does not include the new authToken


  Background:
    Given I send and accept JSON
    Given there is a user

  Scenario: The request contains the proper authentication headers
    When I authenticate as user
    And I send a DELETE request to "/users/sign_out"
    Then the response status should be "OK"
    And the json response should not have "authToken"
    And the response should include last href
    And the authentication token should have changed


  Scenario: The authToken in the authentication headers is not correct
    When I authenticate with incorrect token
    And I send a DELETE request to "/users/sign_out"
    Then the response status should be "UNAUTHORIZED"
    And the JSON response at "errors" should be ["You need to sign in or sign up before continuing."]
    And the authentication token should not have changed


  Scenario: There are no authentication headers in the request
    And I send a DELETE request to "/users/sign_out"
    Then the response status should be "UNAUTHORIZED"
    And the JSON response at "errors" should be ["You need to sign in or sign up before continuing."]
    And the authentication token should not have changed