Feature: Show Reference, endpoint: GET references/:UUID
  The response includes the reference object.

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are 5 reference records

  Scenario: I request reference details
    When I send a GET request to "/references/:UUID" for first reference in database
    Then the response status should be "OK"
    And response should include first reference object with all public fields
    And response should include link to endpoint /references

  Scenario: Requesting details of non existing reference
    When I send a GET request to "/references/some_uuid"
    Then the response status should be "NOT FOUND"
    And the JSON response at "errors/details" should be ["Reference not found."]