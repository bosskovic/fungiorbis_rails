Feature: Index references, endpoint:  GET /references
  The response includes an array of species objects

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API

  Scenario: I request index of references
    Given there are 5 reference records
    And I send a GET request to "/references"
    Then the response status should be "OK"
    And the JSON response at "references" should have 5 references
    And the references array should include objects with all public fields
    And response should include link to endpoint /references/{references.id}