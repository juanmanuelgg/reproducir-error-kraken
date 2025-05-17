Feature: My feature

@user1 @web
Scenario Outline: My scenario 2
  Given  I navigate to page "https://www.w3schools.com"
  When I click view with selector "#search2"
  And I enter text "<tecnology> <words_for_reference>"

  Examples:
    | tecnology | words_for_reference |
    |      html |   Element Reference |
    |       css |           Reference |
    |       sql |  Keywords Reference |
