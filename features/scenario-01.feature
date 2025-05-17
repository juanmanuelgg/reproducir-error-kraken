Feature: My feature

@user1 @web
Scenario Outline: My scenario 1
  Given  I navigate to page "https://www.w3schools.com"
  When I click view with selector "#search2"
  And I enter text "<tutorial>"

  Examples:
    | tutorial |
    |     html |
    |      css |
    |      sql |
