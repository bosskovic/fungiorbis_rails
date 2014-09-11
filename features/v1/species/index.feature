Feature: Index species, endpoint:  GET /species
  The response includes an array of species objects

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API

  Scenario: I request index of species
    Given there are 5 species
    And I send a GET request to "/species"
    Then the response status should be "OK"
    And the JSON response at "species" should have 5 species
    And the species array should include objects with fields: name, genus, familia, ordo, subclassis, classis, subphylum, phylum, synonyms