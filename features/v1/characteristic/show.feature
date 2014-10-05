Feature: Show Species Characteristic, endpoint: GET species/:SPECIES_UUID/characteristics/:UUID
  The response includes the characteristic object.

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there is 1 species with characteristics

  Scenario: I request species characteristic details
    When I send a GET request to "/species/:SPECIES_UUID/characteristics/:UUID" for first species and first characteristic in database
    Then the response status should be "OK"
    And response should include first characteristic object with all public fields
    And characteristic should include expanded reference with all public fields
    And response should include link to endpoint /species/{species.id}/characteristics

  Scenario: Requesting details of non existing characteristic
    When I send a GET request to "/species/:SPECIES_UUID/characteristics/some_uuid" for first species and first characteristic in database
    Then the response status should be "NOT FOUND"
    And the JSON response at "errors/details" should be ["Species characteristic not found."]