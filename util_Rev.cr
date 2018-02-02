def checkForSpecial(array)
  if (!array.include?("'"))
    return array
  end
  while (true)
    idx = array.rindex("'")
    if (idx.nil?)
      break
    end
    array[idx] = array[idx - 1] + "'" + array[idx + 1]
    array.delete_at(idx + 1)
    array.delete_at(idx - 1)
  end
  return array
end

def checkForSubstitution(a, b)
  rgx = /([ ]|:|,|\[|\]|\.|\!|\?)/
  diff = a.gsub(/\n/, ' ').split(rgx) - b.gsub(/\n/, ' ').split(rgx)
  if (diff.empty?)
    return false
  end
  p diff
  return diff
end

def cloneTable(a)
  b = [] of Array(Set(Item))
  a.each_with_index do |row, i|
    b.push([] of Set(Item))
    row.each_with_index do |col, j|
      b[i].push(a[i][j].clone)
    end
  end
  return b
end

def mergeTables(a, b)
  a.each_with_index do |row, i|
    row.each_with_index do |col, j|
      a[i][j] = a[i][j] | b[i][j]
    end
  end
  return a
end

def viewTable(t, n)
  html = File.new("table.html", "w")

  html.puts("<!DOCTYPE html> <html lang=\"en\"> <head> <meta charset=\"UTF-8\"> <title>Table Preview</title> </head> <body> <header> </header> <main> <table border = 1> <tbody> <tr>")
  (0..n+1).each do |i|
    if (i == 0)
      html.puts("<td style = \"text-align: center; padding: 25px;\"> <p>&nbsp;</p> </td>")
      next
    end
    html.puts("<td style = \"text-align: center; padding: 25px;\"> <p> #{i - 1} </p> </td>")
  end
  html.puts("</tr>")
  (0..n).each do |r|
    html.puts("<tr>")
    html.puts("<td style = \"text-align: left; padding: 25px;\"> <p> #{r} </p> </td>")
    (0..n).each do |c|
      if (c < r)
        html.puts("<td style = \"text-align: center; padding: 25px; background-color: grey;\"> <p>&nbsp;</p> </td>")
        next
      end
      html.puts("<td style = \"text-align: left; padding: 25px;\">")
      tempPair = Pair.new(r,c)
      if(t.has_key?(tempPair))
        t[tempPair].each do |item|
          html.puts("<p> #{item.string} </p>")
        end
      end
      html.puts("</td>")
    end
    html.puts("</tr>")
  end
  html.puts("
  			</tbody>
  		</table>
  	</main>

  	<footer>

  	</footer>
   </body>

   </html>"
  )

  html.close
end

def viewParseTree(treeNode : TreeNode | Nil)
  graph = File.new("parseTree.dot", "w")
  graph.puts("digraph parseTree{")

  expandTreeNode(graph, treeNode)

  graph.puts("}")
  graph.close

  #Process.run("./pngify.bat")
end

def expandTreeNode(graph : File, treeNode : TreeNode | Nil)
  if (treeNode.nil?)
    return
  end

  graph.puts("\"#{treeNode.index}\" [shape=circle, label=\"Symbol: #{treeNode.symbol}\"];")

  if (treeNode.lexeme != "" && treeNode.symbol != "S'")
    graph.puts("\"#{treeNode.symbol}#{treeNode.index}\" [shape=square, label=\"Lexeme: #{treeNode.lexeme}\"];")
    graph.puts("\"#{treeNode.index}\" -> \"#{treeNode.symbol}#{treeNode.index}\";")
  end

  if (!treeNode.children.empty?)
    treeNode.children.each do |child|
      expandTreeNode(graph, child)
      graph.puts("\"#{treeNode.index}\" -> \"#{child.index}\";")
    end
  end
end

def romanToInt(roman : String)
  int = 0
  previous = 0
  x = roman.size - 1

  while true
    if (x < 0)
      break
    end

    case roman.char_at(x)
    when 'M'
      int = processInt(1000, previous, int)
      previous = 1000
    when 'D'
      int = processInt(500, previous, int)
      previous = 500
    when 'C'
      int = processInt(100, previous, int)
      previous = 100
    when 'L'
      int = processInt(50, previous, int)
      previous = 50
    when 'X'
      int = processInt(10, previous, int)
      previous = 10
    when 'V'
      int = processInt(5, previous, int)
      previous = 5
    when 'I'
      int = processInt(1, previous, int)
      previous = 1
    end

    x -= 1
  end

  return int
end

def processInt(int : Int32, previousNum : Int32, previousInt : Int32)
  if (previousNum > int)
    return previousInt - int
  else
    return previousInt + int
  end
end
