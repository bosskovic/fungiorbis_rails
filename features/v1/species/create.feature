Feature: Adding new Species, endpoint: POST species
  Only supervisors can add species
  The response body is blank, and the header contains location of created resource.

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user, contributor and supervisor
    Given there is 1 species

  Scenario: Supervisor submits only supported fields and adds a species
  Species is created and response body is empty
    Given I authenticate as supervisor
    When I send a POST request to "/species" with all mandatory fields valid
    Then the response status should be "CREATED"
    And location header should include link to created species
    And the JSON response should be empty
    And the species was added to the database

  Scenario: Supervisor submits some unsupported fields along with supported fields
  Species is created and response body contains all public fields of the species
    Given I authenticate as supervisor
    When I send a POST request to "/species" with all mandatory fields valid and "createdAt"
    Then the response status should be "CREATED"
    And location header should include link to created species
    And response should include last species object with all public fields
    And the species was added to the database

  Scenario Outline: Supervisor sends invalid request to add a species
    Given I authenticate as supervisor
    When I send a POST request to "/species" with <invalid_request>
    Then the response status should be "UNPROCESSABLE"
    And the JSON response at "errors/details" should be <errors>
    And the species was not added to the database
  Examples:
    | invalid_request                    | errors                                                                                                                                                                                                       |
    | all mandatory fields missing       | ["Name can't be blank", "Genus can't be blank", "Familia can't be blank", "Ordo can't be blank", "Subclassis can't be blank", "Classis can't be blank", "Subphylum can't be blank", "Phylum can't be blank"] |
    | name-genus not unique              | ["Name - genus combination must be unique"]                                                                                                                                                                  |
    | incorrect value for growthType     | ["Growth type has to be one of: [\"single\", \"group\"]"]                                                                                                                                                    |
    | incorrect value for nutritiveGroup | ["Nutritive group has to be one of: [\"parasitic\", \"mycorrhizal\", \"saprotrophic\", \"parasitic-saprotrophic\", \"saprotrophic-parasitic\"]"]                                                             |


  Scenario Outline: User that is not supervisor tries to add a species
    When I authenticate as <user_or_contributor>
    And I send a POST request to "/species"
    And the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]
  Examples:
    | user_or_contributor |
    | user                |
    | contributor         |

  Scenario: Non authenticated user tries to add a species
    When I send a POST request to "/species"
    And the response status should be "UNAUTHORIZED"
    And the JSON response at "errors/details" should be ["You need to sign in or sign up before continuing."]