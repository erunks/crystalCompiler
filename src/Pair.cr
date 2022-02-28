struct Pair
	property x, y

	def initialize(@x : Int32, @y : Int32)
	end

	def ==(b : Pair) : Bool
		(@x - b.x == 0) && (@y - b.y == 0)
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