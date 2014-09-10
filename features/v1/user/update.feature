Feature: User update
  Any authenticated user can update their user details.
  USER_DETAILS fields are firstName, lastName, institution, title, phone and email.
  If all submitted fields are updated successfully (there were no non-allowed fields in the request), the response body is empty.
  If some fields were skipped (because not in USER_DETAILS), but the request is otherwise valid, user is updated and the response contains the user object.


  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user and supervisor
    Given I authenticate as user


  Scenario: updating all fields except email; no non-permitted fields in the request
    When I send a PATCH request to "/users/:UUID" with updated fields "firstName, lastName, institution, title, phone" for current user
    Then the response status should be "NO CONTENT"
    And user fields "firstName, lastName, institution, title, phone" were updated

  Scenario: user updates all fields except email; "updatedAt" is among non-permitted fields in the request
    When I send a PATCH request to "/users/:UUID" with updated fields "firstName, lastName, institution, title, phone and updatedAt" for current user
    Then the response status should be "OK"
    And response should include my user fields firstName, lastName, email, title, institution, phone, role and no authToken
    And user fields "firstName, lastName, institution, title, phone" were updated
    And user field "role" was not updated

  Scenario: user updates some fields including email; no non-permitted fields in the request
    When I send a PATCH request to "/users/:UUID" with updated fields "firstName, lastName and email" for current user
    Then the response status should be "OK"
    And response should include my user fields firstName, lastName, email, title, institution, phone, role, unconfirmedEmail and no authToken
    And user fields "firstName, lastName, unconfirmedEmail" were updated
    And user field "email" was not updated

  Scenario: The "plain" user tries to update another user
    When I send a PATCH request to "/users/:UUID" with updated fields "firstName, lastName" for other user
    Then the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]

  Scenario: The "plain" user requests details of non existing user
    When I send a PATCH request to "/users/some_uuid" with updated fields "firstName, lastName" for other user
    Then the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]