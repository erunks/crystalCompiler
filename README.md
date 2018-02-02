How to run the Crystal code: 

1. Check to make sure Crystal is installed by using the command "crystal" in the terminal
	1.1. If Crystal is not installed consult the installation guide which can be found here: https://crystal-lang.org/docs/installation/

2. To build a Crystal program use the command "build" followed by the file to build
	ex. crystal build [file] --release --error-trace
	
	With the release and error-trace flags set during the build, this will allow for the built code
to be optimized to the full potential of Crystal's capability, while the error-trace flag shows the
stack trace for any errors which may occur

	2.1 If you don't wish to build a crystal program, you can alternatively run any program using the "run" command
		ex. crystal run [file] --error-trace

	2.2 To run a crystal program with command line arguments it would look like the following:
		ex. crystal run [file] [flags] -- [arguments]
		
3. Once you have a built crystal program, to run it, simpily type the file name prepended by a "./" into the terminal
	ex. ./[file]

	3.1 To run a built crystal program with command line arguments it would look like the following:
		ex. ./[file] [arguments]
		
4. Now you're coding with Crystal!