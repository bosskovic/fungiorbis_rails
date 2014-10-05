Feature: Adding new Species Characteristics, endpoint: POST species/:SPECIES_UUID/characteristics
  Only supervisors can add characteristics
  The response body is blank, and the header contains location of created characteristics.

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user, contributor and supervisor
    Given there is 1 species with characteristics

  Scenario: Supervisor submits only supported fields and adds a characteristic
  Characteristic is created and response body is empty
    Given I authenticate as supervisor
    When I send a POST request to "/species/:SPECIES_UUID/characteristics" with all mandatory fields valid
    Then the response status should be "CREATED"
    And location header should include link to created characteristic
    And the JSON response should be empty
    And the characteristic was added to the database

  Scenario: Supervisor submits some unsupported fields along with supported fields
  Characteristic is created and response body contains all public fields of the characteristic
    Given I authenticate as supervisor
    When I send a POST request to "/species/:SPECIES_UUID/characteristics" with all mandatory fields valid and "createdAt"
    Then the response status should be "CREATED"
    And location header should include link to created characteristic
    And response should include last characteristic object with all public fields
    And the characteristic was added to the database

  Scenario Outline: Supervisor sends invalid request to add a characteristic
    Given I authenticate as supervisor
    When I send a POST request to "/species/:SPECIES_UUID/characteristics" with <invalid_request>
    Then the response status should be "UNPROCESSABLE"
    And the JSON response at "errors/details" should be <errors>
    And the characteristic was not added to the database
  Examples:
    | invalid_request                      | errors                                                                                                |
    | non-existing species uuid in request | ["Species not found."]                                                                                |
    | all mandatory fields missing         | ["Reference not found."]                                                                              |
    | incorrect habitat                    | ["Habitats have to be included in: [\"forest\", \"meadow\", \"sands\", \"peat\", \"anthropogenic\"]"] |
    | incorrect subhabitat                 | ["Habitats must take subhabitats from the list for specific habitat"]                                 |
    | incorrect species                    | ["Habitats must take species from the list for specific habitat and subhabitat"]                      |


  Scenario Outline: User that is not supervisor tries to add a characteristic
    When I authenticate as <user_or_contributor>
    And I send a POST request to "/species/:SPECIES_UUID/characteristics" with all mandatory fields valid
    And the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]
  Examples:
    | user_or_contributor |
    | user                |
    | contributor         |

  Scenario: Non authenticated user tries to add a characteristic
    When I send a POST request to "/species/:SPECIES_UUID/characteristics" with all mandatory fields valid
    And the response status should be "UNAUTHORIZED"
    And the JSON response at "errors/details" should be ["You need to sign in or sign up before continuing."]