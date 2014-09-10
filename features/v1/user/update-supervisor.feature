Feature: User update
  USER_DETAILS fields are firstName, lastName, institution, title, phone and email.
  Supervisors can update USER_DETAILS of any user.
  If all submitted fields are updated successfully (there were no non-allowed fields in the request), the response body is empty.
  If some fields were skipped (because not in USER_DETAILS), but the request is otherwise valid, user is updated and the response contains the user object.


  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user and supervisor
    Given I authenticate as supervisor

  Scenario: Supervisor tries to update another user
    When I send a PATCH request to "/users/:UUID" with updated fields "firstName, lastName" for other user
    Then the response status should be "NO CONTENT"
    And user fields "firstName, lastName" were updated

  Scenario: Supervisor tries to update non existing user
    When I send a PATCH request to "/users/some_uuid" with updated fields "firstName, lastName" for other user
    Then the response status should be "NOT FOUND"
    And the JSON response at "errors/details" should be ["User not found."]