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

  def clone : TreeNode
    TreeNode.new(symbol, lexeme, parent, index, children)
  end

  def to_s : String
    "Symbol: #{symbol}, Lexeme: #{lexeme}, Parent: #{parent.nil? ? Nil : parent}, Children: #{children.size}"
  end

  def has_child?(search : String) : Bool
    !@children.empty? && @children.any? { |child| child.symbol == search }
  end
end
