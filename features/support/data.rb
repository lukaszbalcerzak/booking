class City
	def initialize(name)
		@name = name
	end
	
	def getName
		@name
	end
end

$cityConst = "Prague"

$city1 = City.new("London")
$city2 = City.new("Warsaw")

class User
	def initialize(email, password)
		@email = email
		@password = password
	end
	
	def getEmail
		@email
	end
	
	def getPassword
		@password
	end
end

$user1 = User.new("balci@o2.pl", "bookingbalceusz1")
		