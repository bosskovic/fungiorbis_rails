Feature: Deleting reference, endpoint: DELETE references/:UUID
  Only supervisors can delete reference
  The response body is blank

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user, contributor and supervisor
    Given there is 1 reference

  Scenario: Supervisor sends request to delete a reference
    Given I authenticate as supervisor
    When I send a DELETE request to "/references/:UUID" for the last reference
    Then the response status should be "NO CONTENT"
    And the last reference was deleted

  Scenario: Supervisor sends request to delete a non existing reference
    Given I authenticate as supervisor
    When I send a DELETE request to "/references/some_uuid" for a reference
    Then the response status should be "NOT FOUND"
    And the last reference was not deleted

  Scenario Outline: User that is not supervisor tries to delete last reference
    When I authenticate as <user_or_contributor>
    When I send a DELETE request to "/references/:UUID" for the last reference
    And the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]
    And the last reference was not deleted
  Examples:
    | user_or_contributor |
    | user                |
    | contributor         |

  Scenario: Non authenticated user tries to add a reference
    When I send a DELETE request to "/references/:UUID" for the last reference
    And the response status should be "UNAUTHORIZED"
    And the JSON response at "errors/details" should be ["You need to sign in or sign up before continuing."]