require 'rubygems'
require 'selenium-webdriver'
require 'date'

$first_hotel_name_from_mobile = "Search for hotels on mobile device, first"

#Sample from Marek Szymanski
Then /^I press imageview number (\d+)$/ do |number|
	performAction('wait',3)
	touch(query('ImageView')[number.to_i])
end

#Searching hotels at given location (text)
Then /^I search for hotel in "([^\"]*)"$/ do |location|
	performAction('enter_text_into_numbered_field', " ", 1)
	performAction('wait', 3)
	performAction('enter_text_into_numbered_field', location, 1)
	performAction('wait_for_no_progress_bars')
	performAction('press_list_item', 1, 0)
	performAction('wait', 1)
	performAction('assert_view_property', "search_searchInput", "text", location)
end

#Setting number of nights
Then /^I set number of nights to (\d+)$/ do |nights|
	current = query("* id:'search_nightamount'")[0]["text"].to_i
	if(current > nights.to_i)
		while query("* id:'search_nightamount'")[0]["text"].to_i > nights.to_i
			touch(query("* id:'search_minus_night'")[0])
		end 
	elsif(current < nights.to_i)
		while query("* id:'search_nightamount'")[0]["text"].to_i < nights.to_i
			touch(query("* id:'search_plus_night'")[0])
		end
	end
end

#Setting number of guests
Then /^I set number of guests to (\d+)$/ do |guests|
	current = query("* id:'search_guests'")[0]["text"].to_i
	if(current > guests.to_i)
		while query("* id:'search_guests'")[0]["text"].to_i > guests.to_i
			touch(query("* id:'search_minus_guest'")[0])
		end 
	elsif(current < guests.to_i)
		while query("* id:'search_guests'")[0]["text"].to_i < guests.to_i
			touch(query("* id:'search_plus_guest'")[0])
		end
	end
end

#Complex search for hotel in location at specifed date with given number of guests and nights for
Then /^I search for hotel in "([^\"]*)" for (\d+) guests for (\d+) nights starting from "([^\"]*)"$/ do |location, guests, nights, date| 
	#Set location (exception handling!)
	performAction('enter_text_into_numbered_field', " ", 1)
	performAction('wait', 3)
	performAction('enter_text_into_numbered_field', location, 1)
	performAction('wait_for_no_progress_bars')
	begin
		touch(query("TextView")[0])
	rescue
		raise "No location found!"
	end
	performAction('wait', 3)
	#Set number of guests
	macro("I set number of nights to #{nights}")
	#Set number of nights
	macro("I set number of guests to #{guests}")
	#Set the date
	performAction('press', "Check-in date")
	performAction('set_date_with_index', date, 1)
	performAction('press', "Set")
	#Click search
	performAction('wait', 3)
	performAction('press_button_number', 1) #go to the hotels list
	performAction('wait', 3)
	performAction('press_button_number', 1) #clear pop-ups 
	
	$first_hotel_name_from_mobile = query("* id:'sresult_hotelname'")[0]["text"]
end

#Log-in with user name and password
Then /^I login as "([^\"]*)" with password "([^\"]*)"$/ do |email, password|
	touch(query("*")[5])
	performAction('enter_text_into_id_field', eval(email), "user_email")
	performAction('enter_text_into_id_field', eval(password), "user_password")
	performAction('click_on_view_by_id', "sign_in_button")
end

#Indicating given rate hotels only
Then /^I find only "([^\"]*)" rated hotels$/ do |rate|
	performAction('wait', 3)
	query("TextView id:'sresult_ratingtext'").each do |x|
		if x["text"].start_with? rate
			puts "Found #{rate} hotel"
		end
	end
end

#----------------------------- FINDING HOTELS ----------------------------- 

def getHotels(location, guests, nights, date)
	driver = Selenium::WebDriver.for :firefox #:chrome - doesn't work
	driver.get "http://www.booking.com/index.html?sid=54ed2b76a3226a395eaef59463ec70c2;dcid=1&lang=en-gb"
	
	#LOCATION
	destination = driver.find_element :id => 'destination'
	destination.clear
	destination.send_keys location

	#CHECK-IN DAY
	checkin_date = Date.parse(date)
	checkin_day = driver.find_element :id => 'checkin_day'
	days = checkin_day.find_elements :class => 'b_monthdays'
	days.each do |day|
		if day.attribute('value') == checkin_date.day().to_s
			day.click
			break
		end
	end
	
	#CHECK-IN MONTH
	checkin_month = driver.find_element :id => 'checkin_year_month'
	months = checkin_month.find_elements :class => 'b_months'
	months.each do |month|
		if month.attribute('value') == checkin_date.year().to_s + "-" + checkin_date.month().to_s
			month.click
			break
		end
	end

	#CHECK-OUT DAY
	checkout_date = checkin_date + nights.to_i
	checkout_day = driver.find_element :id => 'checkout_monthday'
	days = checkout_day.find_elements :tag_name => 'option'
	days.each do |day|
		if day.attribute('value') == checkout_date.day().to_s
			day.click
			break
		end
	end
	
	#CHECK-OUT MONTH
	checkout_month = driver.find_element :id => 'checkout_year_month'
	months = checkout_month.find_elements :class => 'b_months'
	months.each do |month|
		if month.attribute('value') == checkout_date.year().to_s + "-" + checkout_date.month().to_s
			month.click
			break
		end
	end

	#GUESTS
	more_options = driver.find_element :id => 'predefined_group'
	options = more_options.find_elements :tag_name => 'option'
	options[2].click # Click more options on guests search
	
	checkin_day = driver.find_element :id => 'nr_adults'
	days = checkin_day.find_elements :tag_name => 'option'
	days.each do |day|
		if day.attribute('value') == guests
			day.click
			break
		end
	end	
	
	search_button = driver.find_element :id => 'searchbox_btn'
	search_button.click
	
	begin
		results_table = driver.find_element :class => 'disambiguation_results'
		results = results_table.find_elements :class => 'item_thumb'
		results[0].click
	rescue
		results_table = driver.find_element :id => 'cityWrapper'
		results = results_table.find_elements :class => 'disavatar'
		results[0].click
	end
	driver.quit
end

def getHotelsPro(location, guests, nights, date, reference) #getHotelsPro("London", 2, 2, "28-10-2013", "Hotel Hilton")
	driver = Selenium::WebDriver.for :firefox
	driver.get "http://www.booking.com/index.html?sid=54ed2b76a3226a395eaef59463ec70c2;dcid=1&lang=en-gb"
	#LOCATION
	driver.find_element(:id => 'destination').clear
	driver.find_element(:id => 'destination').send_keys location
	#CHECK-IN DAY
	driver.find_element(:xpath => ".//*[@id='checkin_day']/*[@value='" + Date.parse(date).day().to_s + "']").click
	#CHECK-IN MONTH
	driver.find_element(:xpath => ".//*[@id='checkin_year_month']/*[@value='" + Date.parse(date).year().to_s + "-" + Date.parse(date).month().to_s + "']").click
	#CHECK-OUT DAY
	driver.find_element(:xpath => ".//*[@id='checkout_monthday']/*[@value='" + (Date.parse(date) + nights.to_i).day().to_s + "']").click
	#CHECK-OUT MONTH
	driver.find_element(:xpath => ".//*[@id='checkout_year_month']/*[@value='" + (Date.parse(date) + nights.to_i).year().to_s + "-" + (Date.parse(date) + nights.to_i).month().to_s + "']").click
	#GUESTS
	driver.find_element(:xpath => ".//*[@id='predefined_group']/*[@value='3']").click #More options...
	driver.find_element(:xpath => ".//*[@id='nr_adults']/*[@value='" + guests.to_s + "']").click
	#Search	
	driver.find_element(:id => 'searchbox_btn').click
	#Process the list of results
=begin
	begin
		driver.find_element(:xpath => ".//*[@id='cityWrapper']/*[@class='disavatar']")[0].click
	rescue
		driver.find_element(:xpath => ".//*[@class='disambiguation_results']/*[@class='item_thumb']")[0].click
	end
=end
	begin
		results_table = driver.find_element :class => 'disambiguation_results'
		results = results_table.find_elements :class => 'item_thumb'
		results[0].click
	rescue
		results_table = driver.find_element :id => 'cityWrapper'
		results = results_table.find_elements :class => 'disavatar'
		results[0].click
	end
	#Find requested text - reference
	begin
		driver.find_element(:xpath => ".//*[@id='hotellist_inner']/*/*[@class='sr_item_content']/*[*/text()=\"" + reference + "\"]")
		puts "SUCCESS! \"#{reference}\" is on the list"
	rescue
		puts "Fail :( \"#{reference}\" isn't on the list"
	end
	driver.save_screenshot("./screenshot_firefox.png") #Take a screenshot
	driver.quit
end

Then /^I search for hotel in "([^\"]*)" for (\d+) guests for (\d+) nights starting from "([^\"]*)" on website$/ do |location, guests, nights, date| 
	getHotelsPro(location, guests, nights, date, $first_hotel_name_from_mobile)
end