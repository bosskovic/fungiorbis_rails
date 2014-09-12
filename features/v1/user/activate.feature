Feature: User activation
  Deactivated user is activated by sending any PATCH to that user's endpoint (can be blank)

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there is a deactivated user
    Given I authenticate as deactivated user


  Scenario: deactivated user activates account by passing blank patch request
    Given I send a blank PATCH request to "/users/:UUID" for current user
    Then the response status should be "NO CONTENT"
    And user should be activated

  Scenario: deactivated user activates account by updating account
    Given I send a PATCH request to "/users/:UUID" with updated fields "firstName, lastName, institution, title, phone" for current user
    Then the response status should be "NO CONTENT"
    And user fields "firstName, lastName, institution, title, phone" were updated
    And user should be activated