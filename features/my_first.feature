Feature: Booking.com

@maps
Scenario: Maps testing
	Then I wait for 3 seconds
	Then I press button number 2
	Then I enter "" into input field number 1
	Then I enter "London" into input field number 1
	Then I wait for progress
	Then I press list item number 1
	Then I wait for 1 seconds
	Then I press button number 1
	Then I wait for progress
	Then I wait for 1 seconds
	Then I take a picture
	Then I press button number 1
	Then I wait for 1 seconds
	Then I take a screenshot
	Then I press imageview number 1
	Then I wait for 1 seconds
	Then I take a picture
	
@search
Scenario: Search test
	Then I wait for 3 seconds
	Then I press button number 2
	Then I search for hotel in "London"
	Then I take a picture
	
@homework1-scenario
Scenario: Homework 1 - Scenario for city search with assertion
	When I wait for 3 seconds
	And I press button number 2
	Then I enter "" into input field number 1
	When I enter "London" into input field number 1
	Then I wait for progress
	And I press list item number 1
	And I wait for 1 seconds
	Then the view with id "search_searchInput" should have property "text" = "London"
	And I take a picture

@homework1-step
Scenario: Homework 1 - Step for city search with assertion
	When I wait for 3 seconds
	And I press button number 2
	Then I search for hotel in "$cityConst"
	And I take a picture
	
@homework2-scenario
Scenario: Homework 2 - Scenario for log in
	When I wait for 2 seconds
	And I press button number 2
	Then I take a photo
	
@homework2-step
Scenario: Homework 2 - Step for log in
	When I wait for 2 seconds
	And I press button number 2
	Then I login as "$user1.getEmail" with password "$user1.getPassword"
	Then I wait for 2 seconds
	Then I take a picture
	
@query-steps
Scenario: Query for steps
	When I wait for 3 seconds
	And I press button number 2
	Then I enter "" into input field number 1
	When I enter "Warsaw" into input field number 1
	Then I wait for progress
	Then I wait for 1 seconds
	And I press list item number 1
	And I wait for 1 seconds
	Then I press button number 1
	And I wait for progress
	And I wait for 2 seconds
	Then I press button number 1
	And I wait for 1 seconds
	Then I find only "Fabulous" rated hotels
	And I find only "Poor" rated hotels
	And I take a picture

@selenium
Scenario: Selenium tests
	When I wait for 3 seconds
	And I press button number 2
	Then I search for hotel in "London" for 3 guests for 2 nights starting from "20-10-2013"
	Then I wait for 3 seconds
	Then I take a picture
	Then I search for hotel in "London" for 3 guests for 2 nights starting from "20-10-2013" on website