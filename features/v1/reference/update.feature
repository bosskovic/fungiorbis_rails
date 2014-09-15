Feature: Updating reference, endpoint: PATCH references/:UUID
  Only supervisors can update reference
  Response body of successful update has no content

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user, contributor and supervisor
    Given there is 1 reference

  Scenario: Supervisor updates last reference in the database
    Given I authenticate as supervisor
    When I send a PATCH request to "/references/:UUID" with all public fields updating last reference
    Then the response status should be "NO CONTENT"
    And all public fields of the last reference were updated

  Scenario: Supervisor tries to update some unsupported fields of the last reference in the database
  Only supported fields are updated, and the response contains all reference fields
    Given I authenticate as supervisor
    When I send a PATCH request to "/references/:UUID" with "title, url and updatedAt" updating last reference
    Then the response status should be "OK"
    And response should include first reference object with all public fields
    And "title and url" fields of the last reference were updated

  Scenario Outline: Supervisor sends invalid request to update last reference
    Given I authenticate as supervisor
    When I send a PATCH request to "/references/:UUID" (last reference) with <invalid_request>
    Then the response status should be "UNPROCESSABLE"
    And the JSON response at "errors/details" should be <errors>
    And the reference was not updated in the database
  Examples:
    | invalid_request              | errors                          |
    | url not unique               | ["Url has already been taken"]  |
    | isbn not unique              | ["Isbn has already been taken"] |
    | all mandatory fields removed | ["Title can't be blank"]        |

  Scenario: Supervisor tries to update non-existing reference
    Given I authenticate as supervisor
    When I send a PATCH request to "/references/some_uuid" with all public fields updating a reference
    Then the response status should be "NOT FOUND"
    And the JSON response at "errors/details" should be ["Reference not found."]

  Scenario Outline: User that is not supervisor tries to update last reference
    When I authenticate as <user_or_contributor>
    When I send a PATCH request to "/references/:UUID" with all public fields updating last reference
    And the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]
    And the reference was not updated in the database
  Examples:
    | user_or_contributor |
    | user                |
    | contributor         |

  Scenario: Non authenticated user tries to add a reference
    When I send a PATCH request to "/references/:UUID" with all public fields updating last reference
    And the response status should be "UNAUTHORIZED"
    And the JSON response at "errors/details" should be ["You need to sign in or sign up before continuing."]