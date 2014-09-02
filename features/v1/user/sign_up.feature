Feature: Users sign up, endpoint POST /users
  Sign up is open to all users.
  Mandatory fields are "firstName", "lastName", "email" and "password".
  If "passwordConfirmation" is provided, it must match "password".
  "password" has to be at least 8 characters long and must include at least one of each: lowercase letter, uppercase letter, numeric digit, special character.
  Sign up is not possible with an email that already exists in the db.
  The response should include the provided fields and the authToken.


  Background:
    Given I send and accept JSON


  Scenario: All mandatory fields are provided and are valid
    When I send a POST request to "/users" with firstName, lastName, email, password and matching passwordConfirmation
    Then the response status should be "CREATED"
    And response should include posted (and matched against database) user fields: authToken, firstName, lastName, userHref, role
    And the response should include last href


  Scenario: All mandatory fields are provided and are valid and passwordConfirmation is not provided
    When I send a POST request to "/users" with firstName, lastName, email, password and no passwordConfirmation
    Then the response status should be "CREATED"
    And response should include posted (and matched against database) user fields: authToken, firstName, lastName, userHref, role
    And the response should include last href


  Scenario: Passwords do not match
    When I send a POST request to "/users" with firstName, lastName, email, password and passwordConfirmation that does not match
    Then the response status should be "UNPROCESSABLE"
    And the JSON response at "errors" should be ["Password confirmation doesn't match Password"]
    And the response should include last href
    And the user was not added to the database


  Scenario: Passwords too short
    When I send a POST request to "/users" with firstName, lastName, email and password too short
    Then the response status should be "UNPROCESSABLE"
    And the JSON response at "errors" should be ["Password is too short (minimum is 8 characters)"]
    And the response should include last href
    And the user was not added to the database


  Scenario: Passwords too simple
    When I send a POST request to "/users" with firstName, lastName, email and password too simple
    Then the response status should be "UNPROCESSABLE"
    And the JSON response at "errors" should be ["Password must include at least one of each: lowercase letter, uppercase letter, numeric digit, special character."]
    And the response should include last href
    And the user was not added to the database


  Scenario: Mandatory fields missing
    When I send a POST request to "/users" without mandatory fields
    Then the response status should be "UNPROCESSABLE"
    And the JSON response at "errors" should be ["Email can't be blank", "Password can't be blank", "Password confirmation doesn't match Password", "First name can't be blank", "Last name can't be blank"]
    And the response should include last href


  Scenario: Email is already taken
    Given there is a user
    When I send a POST request to "/users" with firstName, lastName, email and password and passwordConfirmation where posted email already exists in the database
    Then the response status should be "UNPROCESSABLE"
    And the JSON response at "errors" should be ["Email has already been taken"]
    And the response should include last href
    And the user was not duplicated in the database
