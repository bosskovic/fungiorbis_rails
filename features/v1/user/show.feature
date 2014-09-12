Feature: Show User, endpoint: GET users/:UUID
  All authenticated users can request their details.
  The response includes the user object.


  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user, contributor and supervisor

  Scenario: User requests their own details
    Given I authenticate as user
    When I send a GET request to "/users/:UUID" for current user
    Then the response status should be "OK"
    And response should include my user fields firstName, lastName, email, title, institution, phone, role and no authToken
    And response should include link to endpoint /users

  Scenario Outline: User that does not have supervisor privileges requests unknown or a a user other then himself
    When I authenticate as <user_or_contributor>
    When I send a GET request to <forbidden_user>
    Then the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]
  Examples:
    | user_or_contributor | forbidden_user                |
    | user                | "/users/:UUID" for other user |
    | user                | "/users/some_uuid"            |
    | contributor         | "/users/:UUID" for other user |
    | contributor         | "/users/some_uuid"            |