Feature: Updating Species Characteristic, endpoint: PATCH species/:SPECIES_UUID/characteristics/:UUID
  Only supervisors can update characteristic
  Response body of successful update has no content

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user, contributor and supervisor
    Given there is 1 species with characteristics

  Scenario: Supervisor updates last characteristic in the database
    Given I authenticate as supervisor
    When I send a PATCH request to "/species/:SPECIES_UUID/characteristics/:UUID" with all public fields updating a characteristic
    Then the response status should be "NO CONTENT"
    And all public fields of the last characteristic were updated

  Scenario: Supervisor tries to update some unsupported fields of the last characteristic in the database
  Only supported fields are updated, and the response contains all characteristic fields
    Given I authenticate as supervisor
    When I send a PATCH request to "/species/:SPECIES_UUID/characteristics/:UUID" with "edible, cultivated and updatedAt" updating last characteristic
    Then the response status should be "OK"
    And response should include last characteristic object with all public fields
    And "edible and cultivated" fields of the last characteristic were updated

  Scenario Outline: Supervisor sends invalid request to update last characteristic
    Given I authenticate as supervisor
    When I send a PATCH request to "/species/:SPECIES_UUID/characteristics/:UUID" (last characteristic) with <invalid_request>
    Then the response status should be "UNPROCESSABLE"
    And the JSON response at "errors/details" should be <errors>
    And the characteristic was not updated in the database
  Examples:
    | invalid_request                      | errors                                                                                                |
    | incorrect habitat                    | ["Habitats have to be included in: [\"forest\", \"meadow\", \"sands\", \"peat\", \"anthropogenic\"]"] |
    | incorrect subhabitat                 | ["Habitats must take subhabitats from the list for specific habitat"]                                 |
    | incorrect species                    | ["Habitats must take species from the list for specific habitat and subhabitat"]                      |

  Scenario Outline: Supervisor tries to update non-existing characteristic
    Given I authenticate as supervisor
    When I send a PATCH request to "/species/:SPECIES_UUID/characteristics/:UUID" (last characteristic) with <invalid_request>
    Then the response status should be "NOT FOUND"
    And the JSON response at "errors/details" should be <errors>
  Examples:
    | invalid_request                             | errors                                |
    | non-existing species uuid in request        | ["Species characteristic not found."] |
    | non-existing characteristic uuid in request | ["Species characteristic not found."] |

  Scenario Outline: User that is not supervisor tries to update last characteristic
    When I authenticate as <user_or_contributor>
    When I send a PATCH request to "/species/SPECIES_UUID/characteristics/UUID" with all public fields updating last characteristic
    And the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]
    And the characteristic was not updated in the database
  Examples:
    | user_or_contributor |
    | user                |
    | contributor         |

  Scenario: Non authenticated user tries to add a characteristic
    When I send a PATCH request to "/species/SPECIES_UUID/characteristics/UUID" with all public fields updating last characteristic
    And the response status should be "UNAUTHORIZED"
    And the JSON response at "errors/details" should be ["You need to sign in or sign up before continuing."]