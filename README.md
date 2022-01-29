# hamachi-fix-ubuntu20.04-or-newer
Fix for Hamachi crashing on Ubuntu 20.04 or newer

Introduction:
============

Logmein only supports Hamachi for linux on Ubuntu 16. If you try to install it under Ubuntu 20.04, the installation succeeds, but the client crashes periodically, thus losing the connection.

The underlying problem is that the client is malloc()ing memory, in some places it does not initialize the allocated memory to zero, and then at some point, it is accessing it. The other problem this client has is that at some point, it frees those memory blocks, and then tries to read or write to the freed memory areas.

On the older ubuntu 16.x, the default glibc2.23 that it contains is way more tolerant to this problem, but, on Ubuntu 20.xx and newer, the glibc2.31 library performs extensive validations and will assert and not tolerate this misbehaviour (bug) of the client anymore, and will force a crash of the client to force developers to fix the bug.

As this bug has not been addressed by Logmein, and we don't have the source code of the client, i took a different approach: Intercept the client calls to malloc() and actually reserve a little bit more of memory than actually requested by the client, And also force its initialization to 0. And, specifically for the block size (77) that we know is being accessed after it is freed, we have an special memory pool that allows us to let the client access the blocks even after being released.

By doing so, even if the client accesses that "invalid by a few bytes" area of the allocated block of memory, or accesses memory blocks after free()ing them, now it will access a valid area (because the memory block is actually larger than the client thinks and those problematic blocks are recycled, but never freed.

The result is that the client does not crash anymore, and it works!

The way I chose to perform the interception, is by creating a shared library object that exports the malloc() functions, and I force load it with LD_PRELOAD before the client itself. That shared object library calls the original malloc() (glibc) function, but with an increased count of bytes, and returns the newly allocated block to the client.

Also, I intercept the operator new[] and operator delete[] calls, as those are the ones being used to free and then access the already freed memory areas.

To avoid requiring a severe modification to the way the hamachi client is invoked, I also created a small program that wraps the original hamachi client, and performs the preload of the shared object before loading the client itself, so, once installed, this workaround will require no changes to the way hamachi is used or invoked. It just behaves as a fully working hamachi installation on Ubuntu 20.xx

How to install:
==============

You must do it as root, as hamachi is owned by root:

1) Compile the malloc() interceptor shared object library:

	gcc -O2 -Wall -o hamachid-patcher.so -shared hamachid-patcher.c
	
2) Compile the hamachid program wrapper:

	gcc -O2 -Wall -o hamachid hamachid.c
	
3) Rename /opt/logmein-hamachi/bin/hamachid to /opt/logmein-hamachi/bin/hamachid.org

	sudo mv /opt/logmein-hamachi/bin/hamachid /opt/logmein-hamachi/bin/hamachid.org
	
4) Copy both the interceptor (hamachid-patcher.so) and wrapper (hamachid) to /opt/logmein-hamachi/bin

	sudo cp hamachid-patcher.so /opt/logmein-hamachi/bin/
	
	sudo cp hamachid /opt/logmein-hamachi/bin/
	
5) Done!. Hamachi will not crash anymore. If the service is already running, please stop it and start it again, in order to load the patched version

	sudo /etc/init.d/logmein-hamachi stop
	
	sudo /etc/init.d/logmein-hamachi start
	


Pull requests adding a small makefile, or an install script are welcome. 
Also, please report your results. I did only test this on Ubuntu 20.04 LTS 64bit intel

Just as a sidenote:
==================

It is very easy to find the root causes of the crash. I just used valgrind on the compiled hamachi client, and that gave the required insight. Then an small peek into the disassembly convinced me of the problem.
