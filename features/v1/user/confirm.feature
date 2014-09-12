Feature: User confirms the account, endpoint: GET users/confirmation?confirmation_token=CONFIRMATION_TOKEN

  After user signs up, the confirmation email is sent with the confirmation link (this endpoint).
  Requesting the endpoint confirms the account.

  Request with incorrect token, without token or for already confirmed user results in an error (422)
  with appropriate message.


  Background:
    Given I send and accept JSON using version 1 of the fungiorbis API
    Given there are users: confirmed user and unconfirmed user

  Scenario: request with the correct confirmation token
    Given I am an unconfirmed user
    When I send a GET request to "/users/confirmation?confirmation_token=:CONFIRMATION_TOKEN" with my confirmation token
    Then the response status should be "NO CONTENT"
    And my account should be confirmed
    And the JSON response should be empty


  Scenario: request for confirmation of the already confirmed account
    Given I am a confirmed user
    When I send a GET request to "/users/confirmation?confirmation_token=:CONFIRMATION_TOKEN" with my confirmation token
    Then the response status should be "UNPROCESSABLE"
    And the JSON response at "errors/details" should be ["Email was already confirmed, please try signing in"]


  Scenario Outline: request with blank or incorrect confirmation token
    When I send a GET request to "/users/confirmation?confirmation_token=<confirmation_token>"
    Then the response status should be "UNPROCESSABLE"
    And the JSON response at "errors/details" should be ["<error_message>"]
  Examples:
    | confirmation_token | error_message                     |
    | abcd               | Confirmation token is invalid     |
    |                    | Confirmation token can't be blank |