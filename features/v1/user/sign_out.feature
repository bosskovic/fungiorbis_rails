Feature: Users sign out, endpoint: DELETE /users/sign_out
  The request with the proper authentication headers to this endpoint causes the user's authToken to be reset.
  The response is empty.


  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there is a user

  Scenario: The request contains the proper authentication headers
    When I authenticate as user
    And I send a DELETE request to "/users/sign_out"
    Then the response status should be "NO CONTENT"
    And the authentication token should have changed
    And the JSON response should be empty


  Scenario: The authToken in the authentication headers is not correct
    When I authenticate with incorrect token
    And I send a DELETE request to "/users/sign_out"
    Then the response status should be "UNAUTHORIZED"
    And the JSON response at "errors/details" should be ["You need to sign in or sign up before continuing."]
    And the authentication token should not have changed


  Scenario: There are no authentication headers in the request
    And I send a DELETE request to "/users/sign_out"
    Then the response status should be "UNAUTHORIZED"
    And the JSON response at "errors/details" should be ["You need to sign in or sign up before continuing."]
    And the authentication token should not have changed