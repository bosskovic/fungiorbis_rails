Feature: Deleting Species, endpoint: DELETE species/:UUID
  Only supervisors can delete species
  The response body is blank

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user, contributor and supervisor
    Given there is 1 species

  Scenario: Supervisor sends request to delete a species
    Given I authenticate as supervisor
    When I send a DELETE request to "/species/:UUID" for the last species
    Then the response status should be "NO CONTENT"
    And the last species was deleted

  Scenario: Supervisor sends request to delete a non existing species
    Given I authenticate as supervisor
    When I send a DELETE request to "/species/some_uuid" for a species
    Then the response status should be "NOT FOUND"
    And the last species was not deleted

  Scenario Outline: User that is not supervisor tries to delete last species
    When I authenticate as <user_or_contributor>
    When I send a DELETE request to "/species/:UUID" for the last species
    And the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]
    And the last species was not deleted
  Examples:
    | user_or_contributor |
    | user                |
    | contributor         |

  Scenario: Non authenticated user tries to add a species
    When I send a DELETE request to "/species/:UUID" for the last species
    And the response status should be "UNAUTHORIZED"
    And the JSON response at "errors/details" should be ["You need to sign in or sign up before continuing."]