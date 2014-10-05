Feature: Index species, endpoint:  GET /species
  The response includes an array of species objects

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API

  Scenario: I request index of species
    Given there are 5 species with characteristics
    And I send a GET request to "/species"
    Then the response status should be "OK"
    And the JSON response at "species" should have 5 species
    And the species array should include objects with all public fields
    And the characteristic ids should be present in the links object
    And response should include link to endpoint /species/{species.id}