# SlowLox

A 1-to-1 conversion of JLox to Ruby.

For the original code see https://github.com/munificent/craftinginterpreters

## Why?

Lox is a great stepping stone for writing an interpreter for non-lisp-languages. Before this one, there were no Ruby-implementations and I felt like one was needed.
https://github.com/munificent/craftinginterpreters/wiki/Lox-implementations

With this conversion I tried to stick closely to the Java sources so
that beginners can easily read and understand both.

Sometimes I decided to use a different functionality or a shortcut to
achieve the same goal. For those cases I added a lot of documentation
including links to https://ruby-doc.org/ and relevant questions on
stackoverflow.

The coding style is not always consistent because I am working on this code at differing times and without touching files that I am done with again.

But why am I just converting the Java-code instead of following the tutorial?  
The answer: I did follow the the tutorial, but the code is lost because I 
didn't bother creating a git-repo. (Don't be like that, ok?)

## Running it

Go to the main directory, open your command line and run  
``ruby rblox.rb`` Run prompt.  
``ruby rblox.rb <file>`` Run a single lox file and quit.  
``ruby rblox.rb <directory>`` Run all lox files in a directory.  

With the `-repl` (or `-interactive`) option, the prompt is started after executing the normal file or directory:  
``ruby rblox.rb -repl <file>`` Run a single lox file and run prompt.  
``ruby rblox.rb -repl <directory>`` Run all lox files in a directory and run prompt.  

Use the `-test` option to print which file is currently being run.  
``ruby rblox.rb -test <directory>`` Run all lox files in a directory and run prompt.  

## Contributing

Please contact me at any time if you have questions or suggestions.

## What's next?

The code works, but sometimes gives more errors than JLox. Maybe I will take care of this. I will not, however, try to tweak performance.

## About the name...

Yeah, SlowLox is slow. In my tests JLox was 5-14 times faster.

This gets much worse when recursion is used because Ruby is really bad at that.
