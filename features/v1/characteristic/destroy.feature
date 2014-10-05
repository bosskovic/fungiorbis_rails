Feature: Deleting characteristic, endpoint: DELETE species/:SPECIES_UUID/characteristics/:UUID
  Only supervisors can delete characteristic
  The response body is blank

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user, contributor and supervisor
    Given there is 1 species with characteristics

  Scenario: Supervisor sends request to delete a characteristic
    Given I authenticate as supervisor
    When I send a DELETE request to "/species/:SPECIES_UUID/characteristics/:UUID" for the last characteristic
    Then the response status should be "NO CONTENT"
    And the last characteristic was deleted

  Scenario: Supervisor sends request to delete a non existing characteristic
    Given I authenticate as supervisor
    When I send a DELETE request to "/species/:SPECIES_UUID/characteristics/some_uuid" for a characteristic
    Then the response status should be "NOT FOUND"
    And the last characteristic was not deleted

  Scenario Outline: User that is not supervisor tries to delete last characteristic
    When I authenticate as <user_or_contributor>
    When I send a DELETE request to "/species/:SPECIES_UUID/characteristics/:UUID" for the last characteristic
    And the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]
    And the last characteristic was not deleted
  Examples:
    | user_or_contributor |
    | user                |
    | contributor         |

  Scenario: Non authenticated user tries to add a characteristic
    When I send a DELETE request to "/species/:SPECIES_UUID/characteristics/:UUID" for the last characteristic
    And the response status should be "UNAUTHORIZED"
    And the JSON response at "errors/details" should be ["You need to sign in or sign up before continuing."]