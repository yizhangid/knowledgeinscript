First of all, this is an QA Tool. In a nutshell, it computes understand the given syntax (or better phase is: relation) of command options  and outputs all of the possible combination. Here are some example:

Linux command "useradd" has many options, to name a few:
  -m, --create-home             create the user's home directory
  -M, --no-create-home          do not create the user's home directory
  -h, --help                    display this help message and exit  
  -p, --password PASSWORD       encrypted password of the new account
  -r, --system                  create a system account

Assume I need test this command. The first thing I need do is to understand how many possible combinations are there. Obviously, "-h" is stand alone option. It does not work with other options. Option "-m" and "-M" are oppsite to each other, they should not appear at same time -- this is "syntax" of command line options. This web application is to understand this type of syntax and compute all possible combinations for you.

Secondary, this simple web application that based on google app engine could be an alternative example of google's "hello world" -- that one was out dated, some information listed there are not correct.  

Last, the live version is running on: 
http://scenariomath.appspot.com/
