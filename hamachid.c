// gcc -O2 -Wall -o hamachid hamachid.c

#include <stdio.h>
#include <unistd.h>
#include <malloc.h>
#include <string.h>

int main(int argc, char **argv)
{
	int i;
	// Allocate space for the arguments
	char** args = (char**)malloc(sizeof(char*)*(argc+1));
	
	// Copy them
	for (i=0;i<argc;++i) args[i] = strdup(argv[i]);
	args[argc] = NULL;
	
	// Force preloading of our "fixer"
    char *const envs[] = {"LD_PRELOAD=/opt/logmein-hamachi/bin/hamachid-patcher.so", NULL};
	
	// And execute the process
    if (execve("/opt/logmein-hamachi/bin/hamachid.org",args,envs) == -1) {
		perror("Unable to launch /opt/logmein-hamachi/bin/hamachid.org");
	}
	
	// Release memory (not reached)
	free(args);
}