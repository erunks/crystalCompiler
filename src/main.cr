require "./Compiler"

compiler = Compiler.new(ARGV[0])
compiler.compile(compiler.grammer.parseTreeRoot)
exit 0
