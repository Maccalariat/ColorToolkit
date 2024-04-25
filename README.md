# ColorToolkit
A re-imagining of Imatest's Gamutvision in modern matlab

The source code for Imatest's Gamutvision is available on Github at:
https://github.com/imatest/gamutvision.git.

I am extremely grateful to Norman Koren at Imatest for making this code available.
I wanted to learn about color spaces, gamuts etc. and his codebase has been invaluable.

Originally, my plan was to 'modernize' the Gamutvision codebase to use Matlab 2023 capabilities (Application Designer rather than GUIDE, built-in image functions etc.).
I quickly realized that even with Matlab utilities to convert the codebase, the challenge exceed a complete re-write.
In that process I decided to take a more 'use-case' user interface and workflow approach.

In order to use this code base, you require a legal (of course) version of modern Matlab (I used Matlab 2023) and the Image Processing Toolbox.

The entry-point for the application is the script "CTB.m" in the root directory.

Enjoy.

NOTE: Use the Active branch. If I ever get to a good stable, functional release, then I will push that to the main branch.
