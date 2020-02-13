require "./TreeNode"
require "./CFG"

class Compiler
  getter :grammer

  def initialize(file)
    @grammer = CFG.new
    @grammer.constructFromFile("./language.txt")
    if (file.nil?)
      @grammer.tokenizeFile("../correctInputs/1.txt")
    else
      @grammer.tokenizeFile(file)
    end
    before = Time.utc
    @grammer.earleyParse
    p Time.utc - before

    @actors = Set(String).new
    @activeActors = Set(String).new
    @expectedAct = 0
    @actSceneNames = {} of String => String
    @sceneCount = {} of Int32 => Int32
    @addressee = ""
    @addresser = ""
    @comparatee = ""

    gatherActsScenes(grammer.parseTreeRoot.children[0].children[2])
    p @actSceneNames
  end

  def compile(node : TreeNode | Nil)
    if (node.nil?)
      return
    else
      puts "Index: #{node.index} \t Symbol: #{node.symbol} \t Lexeme: #{node.lexeme}"
      if (!node.children.empty?)
        node.children.each do |child|
          analysis(node, child)
          compile(child)
        end
      end
    end
  end

  def analysis(parent : TreeNode | Nil, node : TreeNode | Nil)
    if (node.nil?)
      return
    end

    case node.symbol
    when "ACTOR"
      case parent.symbol
      when "dramatis-personae"
        if (!@actors.includes?(node.lexeme))
          @actors.add(node.lexeme)
          p @actors
        else
          p "AREN'T YOU HERE ALREADY, #{node.lexeme}?"
          exit -1
        end
      when "line"
        if (!@activeActors.includes?(node.lexeme))
          p "WHERE DID YOU COME FROM, #{node.lexeme}?"
          exit -1
        end
      end

      return
    when "enter-stmt"
      if (node.has_child?("actorlist"))
        tempList = gatherActors(node.children[2], [] of String)
        tempList.each do |actor|
          if (!@activeActors.includes?(actor) && @actors.includes?(actor))
            @activeActors.add(actor)
          elsif (@activeActors.includes?(actor))
            p "YOU'RE ALREADY IN THE SCENE, #{actor}!"
            exit -1
          else
            p "NO SNEAKING ONTO THE STAGE, #{actor}!"
            exit -1
          end
        end
      elsif (node.has_child?("ACTOR"))
        child1 = node.children[2]
        if (!@activeActors.includes?(child1.lexeme) && @actors.includes?(child1.lexeme))
          @activeActors.add(child1.lexeme)
        elsif (@activeActors.includes?(child1.lexeme))
          p "YOU'RE ALREADY IN THE SCENE, #{child1.lexeme}!"
          exit -1
        else
          p "NO SNEAKING ONTO THE STAGE, #{child1.lexeme}!"
          exit -1
        end
      end

      p @activeActors

      return
    when "exit-stmt"
      if (node.has_child?("EXIT"))
        child1 = node.children[2]
        if (@activeActors.includes?(child1.lexeme) && @actors.includes?(child1.lexeme))
          @activeActors.delete(child1.lexeme)
        elsif (!@activeActors.includes?(child1.lexeme))
          p "YOU WEREN'T IN THE SCENE, #{child1.lexeme}!"
          exit -1
        else
          p "WHERE DID YOU COME FROM, #{child1.lexeme}?"
          exit -1
        end
      elsif (node.has_child?("EXEUNT"))
        if (node.has_child?("OMNES"))
          @activeActors.clear
        elsif (node.has_child?("actorlist"))
          tempList = gatherActors(node.children[2], [] of String)
          tempList.each do |actor|
            if (@activeActors.includes?(actor) && @actors.includes?(actor))
              @activeActors.delete(actor)
            elsif (!@activeActors.includes?(actor))
              p "YOU WEREN'T IN THE SCENE, #{actor}!"
              exit -1
            else
              p "WHERE DID YOU COME FROM, #{actor}?"
              exit -1
            end
          end
        else
          @activeActors.clear
        end
      else
        p "WHAT HAPPENED HERE?!"
        exit -2
      end

      return
    when "statement"
      @addresser = ""
      @addressee = ""

      return
    when "act"
      @activeActors.clear

      return
    when "scene"
      @activeActors.clear

      return
    when "line"
      if (node.has_child?("optional-addressee"))
        @addressee = node.children[2].children[0].lexeme
      end

      @addresser = node.children[0].lexeme

      return
    when "assignment"
      if (node.children[0].symbol == "YOU" || node.children[0].symbol == "YOURSELF")
        if (@activeActors.size > 1)
          if (@addressee == "" && @activeActors.size != 2)
            p "WHO THE HECK ARE YOU TALKING TO, #{@addresser}?!"
            exit -1
          end
        else
          if (@addressee != "" && !@activeActors.includes?(@addressee))
            p "TALKING ABOUT #{@addressee} BEHIND THEIR BACK IS RUDE, #{@addresser}!"
            exit -1
          elsif (@addressee != "" && @activeActors.includes?(@addressee))
            return
          else
            p "TALKING TO YOURSLEF, #{@addresser}?"
            exit -1
          end
        end
      end

      return
    when "arithmetic"
      if (!@actors.includes?(node.children[0].lexeme) && node.has_child?("ACTOR"))
        p "#{node.children[0].lexeme} HAS NO VALUE, IF THEY DON'T EXIST"
        exit -1
      elsif (node.has_child?("YOURSELF") || node.has_child?("YOU"))
        if (@activeActors.size > 1)
          if (@addressee == "" && @activeActors.size != 2)
            p "CAN'T JUST GET A VALUE FROM ANYONE, #{@addresser}?!"
            exit -1
          end
        else
          if (@addressee != "" && !@activeActors.includes?(@addressee))
            p "#{@addressee} HAS NO VALUE IF THEY DON'T EXIST, #{@addresser}!"
            exit -1
          elsif (@addressee != "" && @activeActors.includes?(@addressee))
            return
          else
            p "NO ONE ELSE AROUND TO GET A VALUE FROM, #{@addresser}?"
            exit -1
          end
        end
      end

      return
    when "goto-target"
      if (node.has_child?("wordlist"))
        title = gatherWordList(node.children[0], "")
        @actSceneNames.each do |k, v|
          if (v == title)
            return
          end
        end

        p "CAN'T GO TO #{title} WHEN IT DOESN'T EXIST, #{@addresser}"
        exit -1
      elsif (node.has_child?("ACT"))
        actNum = romanToInt(node.children[1].lexeme)
        if (@expectedAct < actNum)
          p "WE HAVEN'T GOTTEN TO ACT #{actNum} YET, #{@addresser}"
          exit -1
        else
          if (node.has_child?("SCENE"))
            sceneNum = romanToInt(node.children[4].lexeme)
            if (@sceneCount[actNum] < sceneNum)
              p "SORRY, NO JUMPING TO THE FUTURE, #{@addresser}"
              exit -1
            end
            # p "ACT #{actNum}, SCENE #{sceneNum}"
          end
        end
      end

      return
    when "io"
      if(parent.symbol == "wordP")
        return
      end
      
      if(@activeActors.size > 1)
        if(@addressee == "" && @activeActors.size != 2)
          p "CAN'T JUST GET ANYONE TO OPEN THEIR HEART, #{@addresser}?!"
          exit -1
        elsif(@addressee != "" && @activeActors.size >= 2)
          return
        end
      else
        if (@addressee != "" && !@activeActors.includes?(@addressee))
          p "CAN'T OPEN #{@addressee}'s HEART IF THEY'RE NOT ON STAGE, #{@addresser}!"
          exit -1
        elsif (@addressee != "" && @activeActors.includes?(@addressee))
          return
        else
          p "NO ONE ELSE ON STAGE TO OPEN THEIR HEART, #{@addresser}?!"
          exit -1
        end
      end

      return
    when "stackop"
      if(@activeActors.size > 1)
        if(@addressee == "" && @activeActors.size != 2)
          p "CAN'T JUST GET ANYONE TO REMEMBER, #{@addresser}?!"
          exit -1
        elsif(@addressee != "" && @activeActors.size >= 2)
          return
        end
      else
        if (@addressee != "" && !@activeActors.includes?(@addressee))
          p "CAN'T REMEMBER #{@addressee} IF THEY'RE NOT ON STAGE, #{@addresser}!"
          exit -1
        elsif (@addressee != "" && @activeActors.includes?(@addressee))
          return
        else
          p "NO ONE ELSE ON STAGE TO REMEMBER, #{@addresser}?!"
          exit -1
        end
      end

    when "question"
      case node.children[0].symbol
      when "ARE"
        if (@activeActors.size > 1)
          if (@addressee == "" && @activeActors.size != 2)
            p "WHO THE HECK ARE YOU QUESTIONING, #{@addresser}?"
            exit -1
          end
        else
          if (@addressee != "" && !@activeActors.includes?(@addressee))
            p "CAN'T ASK #{@addressee} A QUESTION IF THEY'RE NOT HERE, #{@addresser}!"
            exit -1
          elsif (@addressee != "" && @activeActors.includes?(@addressee))
            return
          else
            p "QUESTIONING YOURSLEF, #{@addresser}?"
            exit -1
          end
        end

        return
      when "IS"


        return
      when "AM"
        @comparatee = node.children[1].lexeme

        return
      end

      return
    else
      # p "Active sctors: #{@actors}"
      return
    end
  end

  def gatherActors(node : TreeNode, list : Array(String))
    if (node.has_child?("actorlist"))
      list.push(node.children[0].lexeme)
      return gatherActors(node.children[2], list)
    else
      list.push(node.children[0].lexeme)
      if (node.children.size == 3)
        list.push(node.children[2].lexeme)
      end

      return list
    end
  end

  def gatherActsScenes(node : TreeNode)
    #p "Expected Act: #{@expectedAct}"
    #p "Scene Count: #{@sceneCount}"
    #p "Names: #{@actSceneNames}"

    case node.symbol
    when "actlist"
      @expectedAct += 1
      gatherActsScenes(node.children[0])
      if (node.has_child?("actlist"))
        gatherActsScenes(node.children[1])
      end

      return
    when "scenelist"
      @sceneCount[@expectedAct] = @sceneCount[@expectedAct] + 1
      gatherActsScenes(node.children[0])
      if (node.has_child?("scenelist"))
        gatherActsScenes(node.children[1])
      end

      return
    when "act"
      @activeActors.clear
      actNum = romanToInt(node.children[1].lexeme)
      if (actNum == @expectedAct)
        @actSceneNames["#{@expectedAct}:0"] = gatherWordList(node.children[3], "")
        p @actSceneNames
        if (!@sceneCount.has_key?(@expectedAct))
          @sceneCount[@expectedAct] = 0
        end
      elsif (actNum < @expectedAct)
        p "NO REPEATING ACTS!"
        exit -1
      else
        p "NO SKIPPING ACTS!"
        exit -1
      end

      if(node.has_child?("scenelist"))
        gatherActsScenes(node.children[5])
      end

      return
    when "scene"
      @activeActors.clear
      sceneNum = romanToInt(node.children[1].lexeme)
      if (sceneNum == @sceneCount[@expectedAct])
        @actSceneNames["#{@expectedAct}:#{@sceneCount[@expectedAct]}"] = gatherWordList(node.children[3], "")
        p @actSceneNames
      elsif (sceneNum > @sceneCount[@expectedAct])
        p "NO SKIPPING SCENES!"
        exit -1
      else
        p "NO REPEATING SCENES!"
        exit -1
      end

      return
    end
  end

  def gatherWordList(node : TreeNode, sentence : String)
    if (node.children.size == 1)
      sentence += node.children[0].children[0].lexeme
    elsif (node.children.size == 2)
      sentence += node.children[0].children[0].lexeme + " "
      return gatherWordList(node.children[1], sentence)
    end

    return sentence
  end
end
