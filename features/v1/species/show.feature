Feature: Show Species, endpoint: GET species/:UUID
  The response includes the species object.

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are 5 species with characteristics

  Scenario: I request species details
    When I send a GET request to "/species/:UUID" for first species in database
    Then the response status should be "OK"
    And response should include first species object with all public fields
    And species should include array of characteristics with all public fields
    And characteristic should include expanded reference with all public fields
    And response should include link to endpoint /species

  Scenario: Requesting details of non existing species
    When I send a GET request to "/species/some_uuid"
    Then the response status should be "NOT FOUND"
    And the JSON response at "errors/details" should be ["Species not found."]