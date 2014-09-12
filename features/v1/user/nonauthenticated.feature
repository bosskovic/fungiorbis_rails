Feature: Non-authenticated users
  Access to restricted resources is not granted to non-authenticated users


  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user and supervisor

  Scenario Outline: User tries to authenticate with valid or invalid email and invalid token
    When I authenticate <as_invalid_user>
    And I send a GET request to "/users"
    And the response status should be "UNAUTHORIZED"
    And the JSON response at "errors/details" should be ["You need to sign in or sign up before continuing."]
  Examples:
    | as_invalid_user         |
    | as unknown user      |
    | with incorrect token |

  Scenario: Non authenticated user tries to index users
    When I send a GET request to "/users"
    And the response status should be "UNAUTHORIZED"
    And the JSON response at "errors/details" should be ["You need to sign in or sign up before continuing."]


  Scenario: Non authenticated user tries to show a user
    When I send a GET request to "/users/some_uuid"
    Then the response status should be "UNAUTHORIZED"
    And the JSON response at "errors/details" should be ["You need to sign in or sign up before continuing."]


  Scenario: Non authenticated user tries to update a user
    When I send a PATCH request to "/users/some_uuid" with updated fields "firstName, lastName" for other user
    Then the response status should be "UNAUTHORIZED"
    And the JSON response at "errors/details" should be ["You need to sign in or sign up before continuing."]
