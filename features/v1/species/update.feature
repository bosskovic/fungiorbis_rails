Feature: Updating species, endpoint: PATCH species/:UUID
  Only supervisors can update species
  Species characteristics can not be updated through updating species (they are ignored)
  Response body of successful update has no content

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user, contributor and supervisor

  Scenario: Supervisor updates last species in the database
    Given there is 1 species with characteristics
    And I authenticate as supervisor
    When I send a PATCH request to "/species/:UUID" with all public fields updating last species
    Then the response status should be "NO CONTENT"
    And all public fields of the last species were updated
    And species characteristics were not changed

  Scenario: Supervisor tries to update some unsupported fields of the last species in the database
  Only supported fields are updated, and the response contains all species fields
    Given there is 1 species with characteristics
    And I authenticate as supervisor
    When I send a PATCH request to "/species/:UUID" with "familia, ordo and updatedAt" updating last species
    Then the response status should be "OK"
    And response should include first species object with all public fields
    And "familia and ordo" fields of the last species were updated
    And species characteristics were not changed

  Scenario: Supervisor updates some public fields; species characteristics were not changed even though they were sent
    Given there is 1 species with characteristics
    And I authenticate as supervisor
    When I send a PATCH request to "/species/:UUID" with "familia, ordo and characteristics" updating last species
    Then the response status should be "NO CONTENT"
    And "familia and ordo" fields of the last species were updated
    And species characteristics were not changed

  Scenario Outline: Supervisor sends invalid request to update last species
    Given there is 1 species
    And I authenticate as supervisor
    When I send a PATCH request to "/species/:UUID" (last species) with <invalid_request>
    Then the response status should be "UNPROCESSABLE"
    And the JSON response at "errors/details" should be <errors>
    And the species was not updated in the database
  Examples:
    | invalid_request                    | errors                                                                                                                                                                                                       |
    | name-genus not unique              | ["Name - genus combination must be unique"]                                                                                                                                                                  |
    | incorrect value for growthType     | ["Growth type has to be one of: [\"single\", \"group\"]"]                                                                                                                                                    |
    | incorrect value for nutritiveGroup | ["Nutritive group has to be one of: [\"parasitic\", \"mycorrhizal\", \"saprotrophic\", \"parasitic-saprotrophic\", \"saprotrophic-parasitic\"]"]                                                             |
    | all mandatory fields removed       | ["Name can't be blank", "Genus can't be blank", "Familia can't be blank", "Ordo can't be blank", "Subclassis can't be blank", "Classis can't be blank", "Subphylum can't be blank", "Phylum can't be blank"] |

  Scenario: Supervisor tries to update non-existing species
    Given there is 1 species
    And I authenticate as supervisor
    When I send a PATCH request to "/species/some_uuid" with all public fields updating a species
    Then the response status should be "NOT FOUND"
    And the JSON response at "errors/details" should be ["Species not found."]

  Scenario Outline: User that is not supervisor tries to update last species
    Given there is 1 species
    And I authenticate as <user_or_contributor>
    When I send a PATCH request to "/species/:UUID" with all public fields updating last species
    And the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]
    And the species was not updated in the database
  Examples:
    | user_or_contributor |
    | user                |
    | contributor         |

  Scenario: Non authenticated user tries to add a species
    Given there is 1 species
    When I send a PATCH request to "/species/:UUID" with all public fields updating last species
    And the response status should be "UNAUTHORIZED"
    And the JSON response at "errors/details" should be ["You need to sign in or sign up before continuing."]