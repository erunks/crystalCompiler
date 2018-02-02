struct Item
  property lhs, rhs, dpos, origin, ref

  def initialize(@lhs : String, @rhs : Array(String), @dpos : Int32, @origin : String, @ref : Array(Item))
  end

  def string
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
    else
      return "#{lhs} -> #{r = rhs.join(" ").insert(dpos, '•')}, #{origin}"
    end
  end

  def atDpos
    return rhs[dpos]
  end

  def col
    temp = origin.split(/[ :]/)
    return temp[4].to_i32
  end

  def row
    temp = origin.split(/[ :]/)
    return temp[1].to_i32
  end

  def ==(b)
    return (self.hash == b.hash) ? true : false
  end

  def hash
    return {:lhs => lhs, :rhs => rhs, :dpos => dpos, :origin => origin}.hash
  end

  def clone
    return Item.new(lhs, rhs, dpos, origin, ref)
  end
end
