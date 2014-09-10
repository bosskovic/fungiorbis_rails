Feature: Show User, endpoint: GET users/:UUID
  All authenticated users can request their details.
  The response includes the user object.


  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user, contributor and supervisor
    Given I authenticate as user

  Scenario: User requests their own details
    When I send a GET request to "/users/:UUID" for current user
    Then the response status should be "OK"
    And response should include my user fields firstName, lastName, email, title, institution, phone, role and no authToken
    And response should include link to endpoint /users

  Scenario: User requests details of another user
    When I send a GET request to "/users/:UUID" for other user
    Then the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]

  Scenario: User requests details of non existing user
    When I send a GET request to "/users/some_uuid"
    Then the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]


  Scenario: Contributor requests details of non existing user
    When I authenticate as contributor
    And I send a GET request to "/users/some_uuid"
    Then the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]