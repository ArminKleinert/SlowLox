# RbLox
A 1-to-1 conversion of JLox to Ruby.

For the original code see https://github.com/munificent/craftinginterpreters

## Why?

Lox is a great stepping stone for writing an interpreter for non-lisp-languages.
Sadly it seems like there are no Ruby implementations yet.

With this conversion I tried to stick closely to the Java sources so
that beginners can easily read and understand both.

Sometimes I decided to use a different functionality or a shortcut to
achieve the same goal. For those cases I added a lot of documentation
including links to https://ruby-doc.org/ and relevant questions on
stackoverflow.

The coding style is not consistent because I am working on this code at
differing times and without touching files that I am done with again.

But why am I just converting the Java-code instead of following the tutorial?
The answer: I did follow the the tutorial, but the code is lost because I 
didn't bother creating a git-repo. (Don't be like that, ok?)

## Running it

Go to the main directory, open your command line and run  
``ruby rblox.rb``

## Contributing

Please contact me at any time if you have questions or suggestions.

## What's next?

A lot of coding and a lot of tests remain. This code is definitly not
"production ready". Since I am converting the code file-by-file
instead of following the tutorial again, it will take some time.

When I am done with this, I will try to aggressively optimize the code in 
a new repository with less care for style-guides and the original code.
My eventual target is to reach the performance of the original with
at least 2 different Ruby-implementations.
