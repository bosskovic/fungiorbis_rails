Feature: Adding new References, endpoint: POST references
  Only supervisors can add references
  The response body is blank, and the header contains location of created resource.

  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: user, contributor and supervisor
    Given there is 1 reference

  Scenario: Supervisor submits only supported fields and adds a reference
  Reference is created and response body is empty
    Given I authenticate as supervisor
    When I send a POST request to "/references" with all mandatory fields valid
    Then the response status should be "CREATED"
    And location header should include link to created reference
    And the JSON response should be empty
    And the reference was added to the database

  Scenario: Supervisor submits some unsupported fields along with supported fields
  Reference is created and response body contains all public fields of the reference
    Given I authenticate as supervisor
    When I send a POST request to "/references" with all mandatory fields valid and "createdAt"
    Then the response status should be "CREATED"
    And location header should include link to created reference
    And response should include last reference object with all public fields
    And the reference was added to the database

  Scenario Outline: Supervisor sends invalid request to add a reference
    Given I authenticate as supervisor
    When I send a POST request to "/references" with <invalid_request>
    Then the response status should be "UNPROCESSABLE"
    And the JSON response at "errors/details" should be <errors>
    And the reference was not added to the database
  Examples:
    | invalid_request              | errors                          |
    | all mandatory fields missing | ["Title can't be blank"]        |
    | url not unique               | ["Url has already been taken"]  |
    | isbn not unique              | ["Isbn has already been taken"] |


  Scenario Outline: User that is not supervisor tries to add a reference
    When I authenticate as <user_or_contributor>
    And I send a POST request to "/references"
    And the response status should be "FORBIDDEN"
    And the JSON response at "errors/details" should be ["Insufficient privileges"]
  Examples:
    | user_or_contributor |
    | user                |
    | contributor         |

  Scenario: Non authenticated user tries to add a reference
    When I send a POST request to "/references"
    And the response status should be "UNAUTHORIZED"
    And the JSON response at "errors/details" should be ["You need to sign in or sign up before continuing."]