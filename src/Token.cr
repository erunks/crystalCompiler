class Token
  getter :terminal, :line, :lexeme

  def initialize(t : String, li : Int32, le : String)
    @terminal = t
    @line = li
    @lexeme = le
  end

  def class : String
    "Token"
  end

  def string : String
    "#{terminal}\tline=#{line}\tlexeme=#{lexeme}"
  end

  # def ==(b)
  #  if (b == nil)
  #    return false
  #  end
  #  if ((@terminal == b.terminal) && (@line == b.line) && (@lexeme == b.lexeme))
  #    return true
  #  else
  #    return false
  #  end
  # end
end
