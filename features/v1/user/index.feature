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
    And the users array should include my user with firstName, lastName, email, title, institution, phone, role and no authToken


  Scenario: Authenticated user is "plain" user
    When I authenticate as user
    And I send a GET request to "/users"
    Then the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]


  Scenario: Authenticated user is contributor
    When I authenticate as contributor
    And I send a GET request to "/users"
    Then the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]