Feature: Show Species, endpoint: GET species/:UUID
  The response includes the species object.

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are 5 species

  Scenario: I request species details
    When I send a GET request to "/species/:UUID" for first species in database
    Then the response status should be "OK"
    And response should include first species object with all public fields
    And response should include link to endpoint /species