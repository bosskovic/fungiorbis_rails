Feature: Users sign up, endpoint POST /users
  Sign up is open to all users.
  Mandatory fields are "firstName", "lastName", "email" and "password".
  If "passwordConfirmation" is provided, it must match "password".
  "password" has to be at least 8 characters long and must include at least one of each: lowercase letter, uppercase letter, numeric digit, special character.
  Sign up is not possible with an email that already exists in the db.
  The response is empty with location of the created user in the header.


  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API


  Scenario: All mandatory fields are provided and are valid
    When I send a POST request to "/users" with firstName, lastName, email, password and matching passwordConfirmation
    Then the response status should be "CREATED"
    And location header should include link to created user
    And the JSON response should be empty


  Scenario: All mandatory fields are provided and are valid and passwordConfirmation is not provided
    When I send a POST request to "/users" with firstName, lastName, email, password and no passwordConfirmation
    Then the response status should be "CREATED"
    And location header should include link to created user
    And the JSON response should be empty


  Scenario: Passwords do not match
    When I send a POST request to "/users" with firstName, lastName, email, password and passwordConfirmation that does not match
    Then the response status should be "UNPROCESSABLE"
    And the JSON response at "errors/details" should be ["Password confirmation doesn't match Password"]
    And the user was not added to the database


  Scenario: Passwords too short
    When I send a POST request to "/users" with firstName, lastName, email and password too short
    Then the response status should be "UNPROCESSABLE"
    And the JSON response at "errors/details" should be ["Password is too short (minimum is 8 characters)"]
    And the user was not added to the database


  Scenario: Passwords too simple
    When I send a POST request to "/users" with firstName, lastName, email and password too simple
    Then the response status should be "UNPROCESSABLE"
    And the JSON response at "errors/details" should be ["Password must include at least one of each: lowercase letter, uppercase letter, numeric digit, special character."]
    And the user was not added to the database


  Scenario: Mandatory fields missing
    When I send a POST request to "/users" without mandatory fields
    Then the response status should be "UNPROCESSABLE"
    And the JSON response at "errors/details" should be ["Email can't be blank", "Password can't be blank", "Password confirmation doesn't match Password", "First name can't be blank", "Last name can't be blank"]


  Scenario: Email is already taken
    Given there is a user
    When I send a POST request to "/users" with firstName, lastName, email and password and passwordConfirmation where posted email already exists in the database
    Then the response status should be "UNPROCESSABLE"
    And the JSON response at "errors/details" should be ["Email has already been taken"]
    And the user was not duplicated in the database