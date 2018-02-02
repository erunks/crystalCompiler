require "set"
require "./Item"
require "./Pair"
require "./Token"
require "./TreeNode"
require "./util_Rev"

class CFG
  getter :variables, :terminals, :productions, :startState, :nullable, :first, :follow, :tokenData, :parseTable, :parseTreeRoot

  def initialize
    @variables = {} of String => Array(String)
    @terminals = {} of String => Array(Regex)
    @productions = {} of String => Array(Regex)
    @startState = ""
    @nullable = [] of String
    @first = {} of String => Set(String)
    @follow = {} of String => Set(String)
    @tokenData = [] of Token
    @parseTable = {} of Pair => Set(Item)
    @treeNodeIndex = 0
    @parseTreeRoot = TreeNode.new
  end

  def string
    s = "Variables: #{@variables}\n"
    s += "Terminals: #{@terminals}\n"
    # s += "Productions: #{@productions}\n"
    s += "Start State: #{@startState}\n"
    return s
  end

  def addProduction(var : String, produce : Regex)
    if !@terminals[var]?
      # @terminals.push(var)
      @terminals[var] = [] of Regex
    end
    # puts "Regexp";
    @terminals[var].push(produce)
  end

  def addProduction(var : String, produce : String)
    if !@variables[var]?
      # @variables.push(var)
      @variables[var] = [] of String
    end
    if (produce.includes?('|'))
      temp = [] of String
      (produce.split('|')).each do |pro|
        temp.push(pro.strip)
      end
      temp.each do |pro|
        if (pro == "\u03BB" || pro == "lambda")
          @terminals[""] = [] of Regex
          @variables[var].push("")
        else
          @variables[var].push(pro)
        end
      end
    else
      if (produce == "\u03BB" || produce == "lambda")
        @terminals[""] = [] of Regex
        @variables[var].push("")
      else
        @variables[var].push(produce)
      end
    end
  end

  def setStart(s : String)
    @startState = s
  end

  def constructFromFile(filename)
    file = File.open(filename, "r")
    state = 0
    file.each_line do |line|
      line = line.chomp
      if (line.empty?)
        state = 1
        next
      end
      s = line.split("->")

      case state
      when 0
        self.addProduction(s[0].strip, Regex.new(s[1].strip, Regex::Options::IGNORE_CASE))
      when 1
        self.addProduction(s[0].strip, s[1].strip)
      end
    end
    @startState = @variables.first[0]
  end

  def findProduction(string)
    list = [@startState]
    seen = [@startState]
    while (!list.includes?(string))
      newList = [] of Array
      list.each do |parse|
        # puts("Current: #{parse}");
        splt = parse.split("")
        splt.each_with_index do |c, i|
          if (/[[:upper:]]/.match(c))
            @productions[c].each do |p|
              newParse = splt
              newParse[i] = p
              newParse = newParse.join
              # puts("New: #{newParse}");
              if (seen.includes?(newParse))
                next
              elsif (newParse.size > string.size)
                next
              end
              if (newParse != string)
                newList.push(newParse)
              else
                return "Parse found! #{newParse}"
              end
            end
          end
        end
      end
      seen.push(newList)
      seen = seen.flatten
      seen = seen.uniq
      list = newList
      if (newList.empty?)
        return "No Parse Found!"
      end
      # puts("New List: #{list}");
    end
  end

  def getMatch!(string)
    @terminals.each do |terminal|
      result = string.match(@productions[terminal][0])
      if (!result.nil?)
        return terminal
      end
    end
    return nil
  end

  def tokenize(string)
    tokens = [] of Token
    idx = 0
    line = 0

    while (idx < string.size)
      found = false

      @terminals.each do |key, value|
        value.each do |products|
          temp = string.match(products, idx)
          if (temp.nil?)
            next
          end
          match = $~
          if (idx == match.begin(0))
            # p match;
            if (match[0].includes?("\n"))
              line += 1
            end
            idx += match[0].size
            tempMatch = match[0].gsub('\n',' ').squeeze(' ')
            if(key == "ACTOR")
              tempMatch = tempMatch.gsub(/\b\w/, &.capitalize)
              #p "ACTOR #{tempMatch}"
            end
            tokens.push(Token.new(key, line, tempMatch))
            found = true
            break
          end
        end
        if (found)
          break
        end
      end
      if (!found)
        if (string[idx] == ('\n'))
          idx += 1
          line += 1
        elsif (string[idx] == (' '))
          idx += 1
        else
          p string[idx]
          raise "Unable to tokenize input. Error on Line: #{line + 1}  Column: #{idx + 1}"
        end
      end
    end
    @tokenData = tokens
    return tokens
  end

  def tokenizeFile(filename)
    file = File.open(filename, "r")
    content = file.gets_to_end

    @tokenData = tokenize(content)
    return makeItNice(@tokenData)
  end

  def makeItNice(tokens)
    string = ""

    tokens.each do |token|
      string += "[ Line: #{token.line},\tToken: #{token.terminal},\tLexeme: #{token.lexeme} ]\n"
    end
    return string
  end

  def calculateFirst
    @terminals.each do |key, terminal|
      @first[key] = Set.new([key])
    end
    tempFirst = @first
    # idx = 1;
    loop do
      # puts("\nITERATIONS: #{idx}")
      @first = @first.merge(tempFirst)
      tempFirst = @first.clone

      @variables.each do |key, value|
        if (!value.empty?)
          # puts("#{key} -> #{value}");
          value.each do |product|
            elements = product.split(' ')
            elements.each_with_index do |term, i|
              if (i >= 1)
                if (!@nullable.includes?(elements[i - 1]))
                  break
                end
              end
              if (!@terminals.includes?(term))
                if (tempFirst[term]? != nil)
                  if (tempFirst[key]? == nil)
                    tempFirst[key] = tempFirst[term]
                  else
                    tempFirst[key] = tempFirst[key] | tempFirst[term]
                  end
                end
                next
              end
              if (tempFirst.has_key?(term) && !tempFirst[term]?)
                # p "#{term} in IF";
                if (tempFirst[key]?)
                  tempFirst[key] = Set.new([term])
                end
                tempFirst[key] = tempFirst[key] | Set.new(tempFirst[term])
              else
                # p "#{term} in ELSE";
                if (tempFirst[key]?)
                  tempFirst[key] = Set.new([term])
                end
                # tempFirst[key] = tempFirst[key];
              end
            end
          end
        else
          # puts("#{key} EMPTY!");
          next
        end
      end
      # idx+=1;
      break if (@first == tempFirst)
    end
  end

  def calculateFollow
    # p "follow"
    @variables.each do |key, value|
      @follow[key] = Set(String).new
    end
    @follow[@startState] = Set.new(["$"])
    tempFollow = @follow
    # idx = 1;
    loop do
      # puts("\nITERATIONS: #{idx}")
      @follow = @follow.merge(tempFollow)
      tempFollow = @follow.clone

      @variables.each do |key, value|
        if (!value.empty?)
          value.each do |product|
            # puts("#{key} -> #{product}")
            elements = product.split(' ')
            elements.each_with_index do |x, i|
              # p i
              breakOut = false
              if (!@terminals.has_key?(x))
                elements[i + 1..elements.size].each do |y|
                  # puts("#{x} : #{y}")
                  if (tempFollow[x]? == nil)
                    tempFollow[x] = Set(String).new
                  else
                    tempFollow[x] = tempFollow[x] | @first[y]
                    if (!@nullable.includes?(y))
                      # puts("#{y} BROKEOUT!");
                      # puts "";
                      breakOut = true
                      break
                    end
                  end
                end

                if (!breakOut)
                  # puts("N == #{key}");
                  # puts("#{tempFollow[x].to_a},#{tempFollow[key].to_a}");
                  tempFollow[x] = tempFollow[x] | tempFollow[key]
                end
              end
            end
          end
        else
          # puts("#{key} EMPTY!");
          next
        end
      end
      # idx+=1;
      break if (@follow == tempFollow)
    end
  end

  def calculateNullable
    masterNull = Set(String).new
    tempNull = masterNull
    loop do
      masterNull = masterNull | tempNull
      tempNull = masterNull.clone
      @variables.each do |key, value|
        # if(masterNull.member?(var)) then next end;
        value.each do |product|
          breakOut = false
          if (!product.empty?)
            product.split(' ').each do |term|
              if (!masterNull.includes?(term))
                breakOut = true
                break
              end
            end
          end
          if (!breakOut)
            tempNull.add(key)
          end
        end
      end
      break if (masterNull == tempNull)
    end
    @nullable = masterNull.to_a
  end

  
  def addEntry?(row : Int32, col : Int32)
    tempPair = Pair.new(row,col)
    if(!@parseTable.has_key?(tempPair))
      @parseTable[tempPair] = Set(Item).new
    end

    return tempPair
  end

  def addItem(item : Item, row : Int32, col : Int32)
    tempPair = addEntry?(row,col)

    @parseTable[tempPair] = @parseTable[tempPair].add(item)
    # SCAN
    if (@tokenData[tempPair.y]? != nil)
      if (@tokenData[tempPair.y].terminal == item.rhs[item.dpos]?)
        tempItem = Item.new(item.lhs, item.rhs, item.dpos + 1, "S #{row} : #{col}", [item])
        tempPair2 = addEntry?(row,col+1)
        if (!@parseTable[tempPair2].includes?(tempItem)) # the item was added
          @parseTable = addItem(tempItem, row, col + 1)
          flag = true
        end
      end
    end

    # PREDICT
    if (item.rhs[item.dpos]? != nil)
      if (@variables.has_key?(item.atDpos))
        @variables[item.atDpos].each do |product|
          if (product == "")
            tempItem = Item.new(item.atDpos, [] of String, 0, "P #{row} : #{col}", [item])
          else
            tempItem = Item.new(item.atDpos, product.split(' '), 0, "P #{row} : #{col}", [item])
          end
          tempPair2 = addEntry?(col,col)
          if (!@parseTable[tempPair2].includes?(tempItem)) # the item was added
            @parseTable = addItem(tempItem, col, col)
            flag = true
          end
        end
      end
    end

    return @parseTable
  end

  def earleyParse
    p "START!"
    n = @tokenData.size                     # length of the tokens we're trying to parse

    @parseTable = addItem(Item.new("S'", ["#{@startState}"], 0, "Start", [] of Item), 0, 0)
    (0..n).each do |col|
      flag = true
      while (flag)
        flag = false
        (0..col).each do |row|
          pair = Pair.new(row,col)
          if(!@parseTable.has_key?(pair))
            next
          end
          @parseTable[pair].each do |item|
            # COMPLETE
            if (item.dpos == item.rhs.size)
              (0..row).each do |k|
                pair2 = Pair.new(k,row)
                if(!@parseTable.has_key?(pair2))
                  next
                end
                @parseTable[pair2].each do |item2|
                  if (item.lhs == item2.rhs[item2.dpos]?)
                    tempItem = Item.new(item2.lhs, item2.rhs, item2.dpos + 1, "C #{row} : #{col}", [item, item2])
                    tempPair = addEntry?(k,col)
                    if (!@parseTable[tempPair].includes?(tempItem)) # the item was added
                      @parseTable = addItem(tempItem, k, col)
                      flag = true
                    end
                  end
                  if ((item.lhs == "S'") && (item.dpos == item.rhs.size) && ((col == n) && (row == 0))) # check if we've found a soultion
                    p "FINISHED!"
                    viewTable(@parseTable, @tokenData.size)
                    root = makeTree(item, TreeNode.new(item.rhs[item.dpos - 1], @tokenData[item.col - 1].lexeme, nil))
                    @parseTreeRoot = root.as(TreeNode)
                    prune?(@parseTreeRoot)
                    viewParseTree(root)
                    return # the table has been made
                  end
                end
              end
            end
          end
        end
      end
    end
    viewTable(@parseTable, @tokenData.size)

    p "fell out"
    exit -1
  end

  def makeTree(item : Item, treeNode : TreeNode)
    # p item.string
    if (item.origin == "Start")
      # p "START"
      treeNode.symbol = "S'"
      treeNode.parent = nil
      return treeNode
    elsif (item.origin[0] == 'S') # SCAN
      # p "SCAN"
      @treeNodeIndex += 1
      temp = TreeNode.new(item.rhs[item.dpos - 1], @tokenData[item.col].lexeme, treeNode, @treeNodeIndex)
      treeNode.children.unshift(temp)
      return makeTree(item.ref[0], treeNode)
    elsif (item.origin[0] == 'P') # PREDICT
      # p "PREDICT"
      return nil
    elsif (item.origin[0] == 'C') # COMPLETE
      # p "COMPLETE"
      completed = item.ref[0] # the node number where the complete was a complete complete (has dpos at the end)
      partial = item.ref[1]   # the node number where the complete was a partial complete (has dpos not at the end)
      @treeNodeIndex += 1
      temp = TreeNode.new(completed.lhs, "", treeNode, @treeNodeIndex)
      treeNode.children.unshift(temp)
      makeTree(completed, temp)
      return makeTree(partial, treeNode)
    end
  end

  def prune?(treeNode : TreeNode)
    if (!treeNode.children.empty?)
      treeNode.children.each_with_index do |child, i|
        if (child.lexeme == "" && child.children.empty?)
          prune(treeNode, child, i)
          prune?(treeNode)
        else
          prune?(child)
        end
      end
    end
  end

  def prune(parent : TreeNode, child : TreeNode, index : Int32)
    parent.children.delete_at(index)
    p "Removed #{child.to_s} from #{parent.to_s}"
  end
end
