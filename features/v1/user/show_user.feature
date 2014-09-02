Feature: Show User, endpoint: GET users/:UUID
  All authenticated users can request their details.
  Authenticated users with "supervisor" role can request details of any user
  Unauthenticated users can not send requests.
  The response includes the user object.


  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user, contributor and supervisor


  Scenario: The "plain" user requests their own details
    When I authenticate as user
    And I send a GET request to "/users/:UUID" for current user
    Then the response status should be "OK"
    And response should include my user fields firstName, lastName, email, title, institution, phone, role, deactivatedAt, createdAt, updatedAt and no authToken
    And the response should include last href


  Scenario: The "plain" user requests details of another user
    When I authenticate as user
    And I send a GET request to "/users/:UUID" for other user
    Then the response status should be "FORBIDDEN"
    And the response should include last href
    And the JSON response at "errors" should be ["Insufficient privileges"]


  Scenario: The request without authentication headers
    When I send a GET request to "/users/some_uuid"
    Then the response status should be "UNAUTHORIZED"
    Then the JSON response at "errors" should be ["You need to sign in or sign up before continuing."]


  Scenario: Supervisor requests details of another user
    When I authenticate as supervisor
    And I send a GET request to "/users/:UUID" for other user
    Then the response status should be "OK"
    And response should include user fields firstName, lastName, email, title, institution, phone, role, deactivatedAt, createdAt, updatedAt and no authToken
    And the response should include last href