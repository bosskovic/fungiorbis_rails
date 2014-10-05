Feature: Index species characteristics, endpoint:  GET /species/:SPECIES_UUID/characteristics
  The response includes an array of species characteristics objects

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API

  Scenario: I request index of characteristics
    Given there are 5 species with characteristics
    And I send a GET request to /species/:SPECIES_UUID/characteristics
    Then the response status should be "OK"
    And the JSON response at "characteristics" should be an array
    And the characteristics array should include objects with all public fields
    And the reference id should be present in the links object
    And response should include link to endpoint /species/{species.id}/characteristics/{characteristics.id}