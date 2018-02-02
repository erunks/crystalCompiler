struct Pair
	property x, y

	def initialize(x : Int32, y : Int32)
		@x = x
		@y = y
	end

	def ==(b : Pair)
		if((@x - b.x) == 0)
			if((@y - b.y) == 0)
				return true
			else
				return false
			end
		else
			return false
		end
	end

	def hash
		return {:x => @x, :y => @y}.hash
	end

	def name
		return "Pair"
	end

	def to_s
		return "#{@x}:#{@y}"
	end
end