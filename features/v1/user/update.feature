Feature: User update
  Any authenticated user can update their user details.
  USER_DETAILS fields are firstName, lastName, institution, title, phone and email.
  If all submitted fields are updated successfully (there were no non-allowed fields in the request), the response body is empty.
  If some fields were skipped (because not in USER_DETAILS), but the request is otherwise valid, user is updated and the response contains the user object.


  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user, contributor and supervisor
    Given I authenticate as user


  Scenario: updating all fields except email; no non-permitted fields in the request
    When I send a PATCH request to "/users/:UUID" with updated fields "firstName, lastName, institution, title, phone" for current user
    Then the response status should be "NO CONTENT"
    And user fields "firstName, lastName, institution, title, phone" were updated

  Scenario Outline: if the request for user update includes unknown or unauthorized fields or if it includes email, the server sends response with the updated user resource
    When I send a PATCH request to "/users/:UUID" with <updated_fields>
    Then the response status should be "OK"
    And response should include <my_user_fields>
    And <user_fields> were updated
    And user field "role" was not updated
  Examples:
    | updated_fields                                                                                 | my_user_fields                                              | user_fields                                                  |
    | updated fields "firstName, lastName, institution, title, phone and updatedAt" for current user | my user object with all public fields                       | user fields "firstName, lastName, institution, title, phone" |
    | updated fields "firstName, lastName and email" for current user                                | my user object with all public fields plus unconfirmedEmail | user fields "firstName, lastName, unconfirmedEmail"          |


  Scenario Outline: Signed in user that is not supervisor tries to update another or non existent user
    When I send a PATCH request to <path> with updated fields "firstName, lastName" for other user
    Then the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]
  Examples:
    | path               |
    | "/users/:UUID"     |
    | "/users/some_uuid" |