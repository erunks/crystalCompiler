struct Pair
	property x, y

	def initialize(x : Int32, y : Int32)
		@x = x
		@y = y
	end

	def ==(b : Pair) : Bool
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

	def hash : UInt64
		{:x => @x, :y => @y}.hash
	end

	def name : String
		"Pair"
	end

	def to_s : String
		"#{@x}:#{@y}"
	end
end