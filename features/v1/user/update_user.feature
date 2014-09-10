Feature: User update
  Any authenticated user can update their user details.
  USER_DETAILS fields are firstName, lastName, institution, title, phone and email.
  Plain users can update their USER_DETAILS.
  Supervisors can update USER_DETAILS of any user.
  Supervisors can change user ROLE of any user
  If all submitted fields are updated successfully (there were no non-allowed fields in the request), the response body is empty.
  If some fields were skipped (because not in USER_DETAILS), but the request is otherwise valid, user is updated and the response contains the user object.

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user and supervisor

  Scenario: user updates all fields except email; no non-permitted fields in the request
    When I authenticate as user
    And I send a PATCH request to "/users/:UUID" with updated fields "firstName, lastName, institution, title, phone" for current user
    Then the response status should be "NO CONTENT"
    And user fields "firstName, lastName, institution, title, phone" were updated

  Scenario: user updates all fields except email; "role" is among non-permitted fields in the request
    When I authenticate as user
    And I send a PATCH request to "/users/:UUID" with updated fields "firstName, lastName, institution, title, phone and role" for current user
    Then the response status should be "OK"
    And response should include my user fields firstName, lastName, email, title, institution, phone, role and no authToken
    And user fields "firstName, lastName, institution, title, phone" were updated
    And user field "role" was not updated

  Scenario: user updates some fields including email; no non-permitted fields in the request
    When I authenticate as user
    And I send a PATCH request to "/users/:UUID" with updated fields "firstName, lastName and email" for current user
    Then the response status should be "OK"
    And response should include my user fields firstName, lastName, email, title, institution, phone, role, unconfirmedEmail and no authToken
    And user fields "firstName, lastName, unconfirmedEmail" were updated
    And user field "email" was not updated

  Scenario: The "plain" user tries to update another user
    When I authenticate as user
    And I send a PATCH request to "/users/:UUID" with updated fields "firstName, lastName" for other user
    Then the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]

  Scenario: Supervisor tries to update another user
    When I authenticate as supervisor
    And I send a PATCH request to "/users/:UUID" with updated fields "firstName, lastName" for other user
    Then the response status should be "NO CONTENT"
    And user fields "firstName, lastName" were updated

  Scenario: Non authenticated user tries to update a user
    When I send a PATCH request to "/users/some_uuid" with updated fields "firstName, lastName" for other user
    Then the response status should be "UNAUTHORIZED"
    And the JSON response at "errors/details" should be ["You need to sign in or sign up before continuing."]


  Scenario: Supervisor tries to update non existing user
    When I authenticate as supervisor
    When I send a PATCH request to "/users/some_uuid" with updated fields "firstName, lastName" for other user
    Then the response status should be "NOT FOUND"
    And the JSON response at "errors/details" should be ["User not found."]


  Scenario: The "plain" user requests details of non existing user
    When I authenticate as user
    When I send a PATCH request to "/users/some_uuid" with updated fields "firstName, lastName" for other user
    Then the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]

  Scenario: supervisor updates fields including user role
    When I authenticate as supervisor
    And I send a PATCH request to "/users/:UUID" with updated fields "firstName, lastName, institution, title, phone and role" for other user
    Then the response status should be "NO CONTENT"
    And user fields "firstName, lastName, institution, title, phone, role" were updated