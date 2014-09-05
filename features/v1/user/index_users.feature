Feature: Index Users, endpoint:  GET /users
  Authenticated users with "supervisor" role can access the list of all users.
  Besides the authentication header, no params are needed.
  The response includes an array of user objects

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user, contributor and supervisor


  Scenario: Authenticated user is supervisor
    When I authenticate as supervisor
    And I send a GET request to "/users"
    Then the response status should be "OK"
    And the JSON response at "users" should have 3 users
    And the users array should include my user with href, firstName, lastName, email, title, institution, phone, role, deactivatedAt, createdAt, updatedAt and no authToken
    And the response should include last href


  Scenario: Authenticated user is "plain" user
    When I authenticate as user
    And I send a GET request to "/users"
    Then the response status should be "FORBIDDEN"
    And the JSON response at "errors" should be ["Insufficient privileges"]
    And the response should include last href


  Scenario: Authenticated user is contributor
    When I authenticate as contributor
    And I send a GET request to "/users"
    Then the response status should be "FORBIDDEN"
    And the JSON response at "errors" should be ["Insufficient privileges"]
    And the response should include last href


  Scenario: Unknown user tries to authenticate
    When I authenticate as unknown user
    And I send a GET request to "/users"
    And the response status should be "UNAUTHORIZED"
    And the JSON response at "errors" should be ["You need to sign in or sign up before continuing."]


  Scenario: User tries to authenticate with incorrect token
    When I authenticate with incorrect token
    And I send a GET request to "/users"
    And the response status should be "UNAUTHORIZED"
    And the JSON response at "errors" should be ["You need to sign in or sign up before continuing."]


  Scenario: No authentication header is sent
    When I send a GET request to "/users"
    And the response status should be "UNAUTHORIZED"
    And the JSON response at "errors" should be ["You need to sign in or sign up before continuing."]