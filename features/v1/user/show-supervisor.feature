Feature: Show User, endpoint: GET users/:UUID
  Authenticated users with "supervisor" role can request details of any user
  The response includes the user object.


  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user, contributor and supervisor
    Given I authenticate as supervisor


  Scenario: Supervisor requests details of another user
    When I send a GET request to "/users/:UUID" for other user
    Then the response status should be "OK"
    And response should include user object with all public fields
    And response should include link to endpoint /users


  Scenario: Supervisor requests details of non existing user
    When I send a GET request to "/users/some_uuid"
    Then the response status should be "NOT FOUND"
    And the JSON response at "errors/details" should be ["User not found."]