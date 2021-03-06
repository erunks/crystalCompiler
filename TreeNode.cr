# struct TreeNode
#  property symbol, lexeme, index, children : Array(TreeNode), parent : TreeNode | Nil
#
#  def initialize
#    @symbol = ""
#    @lexeme = ""
#    @parent = nil
#    @index = 0
#    @children = [] of TreeNode
#  end
#
#  def initialize(@symbol : String, @lexeme = "", @parent = Nil, @index = 0, @children = [] of TreeNode)
#  end
#
#  def initialize(@symbol : String, @lexeme : String, @parent : TreeNode, @index = 0, @children = [] of TreeNode)
#  end
#
#  def clone
#    return TreeNode.new(symbol, lexeme, parent, index, children)
#  end
# end

class TreeNode
  property symbol, lexeme, index, children : Array(TreeNode), parent : TreeNode | Nil

  def initialize
    @symbol = ""
    @lexeme = ""
    @parent = nil
    @index = 0
    @children = [] of TreeNode
  end

  def initialize(@symbol : String, @lexeme = "", @parent = nil, @index = 0, @children = [] of TreeNode)
  end

  def initialize(@symbol : String, @lexeme : String, @parent : TreeNode, @index = 0, @children = [] of TreeNode)
  end

  def clone
    return TreeNode.new(symbol, lexeme, parent, index, children)
  end

  def to_s
    if (@parent != nil)
      return "Symbol: #{@symbol}, Lexeme: #{@lexeme}, Parent: #{@parent.nil?}, Children: #{@children.size}"
    else
      return "Symbol: #{@symbol}, Lexeme: #{@lexeme}, Parent: Nil, Children: #{@children.size}"
    end
  end

  def has_child?(search : String)
    if (@children.empty?)
      return false
    else
      @children.each do |child|
        if (child.symbol == search)
          return true
        end
      end

      return false
    end
  end
end
