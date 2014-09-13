Feature: Changing user role
  Plain users can not change their role
  Supervisors can change user ROLE of any user

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user and supervisor

  Scenario: plain user has role among update parameters and it is ignored; valid params are processed, and response includes the user
    When I authenticate as user
    And I send a PATCH request to "/users/:UUID" with updated fields "firstName, lastName, institution, title, phone and role" for current user
    Then the response status should be "OK"
    And response should include my user object with all public fields
    And user fields "firstName, lastName, institution, title, phone" were updated
    And user field "role" was not updated

  Scenario: supervisor updates fields including user role
    When I authenticate as supervisor
    And I send a PATCH request to "/users/:UUID" with updated fields "firstName, lastName, institution, title, phone and role" for other user
    Then the response status should be "NO CONTENT"
    And user fields "firstName, lastName, institution, title, phone, role" were updated