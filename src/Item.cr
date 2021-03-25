struct Item
  property lhs, rhs, dpos, origin, ref

  def initialize(@lhs : String, @rhs : Array(String), @dpos : Int32, @origin : String, @ref : Array(Item))
  end

  def string : String
    if (dpos != 0)
      length = 0
      (0...dpos).each do |i|
        if (i != dpos)
          length += rhs[i].size + 1
        else
          length += rhs[i].size
        end
      end
      return "#{lhs} -> #{r = rhs.join(" ").insert(length - 1, '•')}, #{origin}"
    end

    "#{lhs} -> #{r = rhs.join(" ").insert(dpos, '•')}, #{origin}"
  end

  def atDpos : String
    rhs[dpos]
  end

  def col : Int32
    temp = origin.split(/[ :]/)
    temp[4].to_i32
  end

  def row : Int32
    temp = origin.split(/[ :]/)
    temp[1].to_i32
  end

  def ==(b) : Bool
    self.hash == b.hash
  end

  def hash : UInt64
    {:lhs => lhs, :rhs => rhs, :dpos => dpos, :origin => origin}.hash
  end

  def clone : Item
    Item.new(lhs, rhs, dpos, origin, ref)
  end
end
