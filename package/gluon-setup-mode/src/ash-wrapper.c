// ash-wrapper:
// a tiny wrapper around /bin/ash that joins the mount namespace of PID1, while
// preserving the value of argv[0] (which is not possible with a script-based
// solution because of the way shebangs work)

#define _GNU_SOURCE

#include <sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/syscall.h>

#define SHELL "/bin/ash"

int main(int argc, char *argv[]) {
	char *cwd = get_current_dir_name();
	if (!cwd) {
		fprintf(stderr, "get_current_dir_name: %m\n");
		return 1;
	}

	int pid1fd = syscall(SYS_pidfd_open, 1, 0);
	if (pid1fd < 0) {
		fprintf(stderr, "pidfd_open: %m\n");
		return 1;
	}

	if (setns(pid1fd, CLONE_NEWNS) < 0) {
		fprintf(stderr, "setns: %m\n");
		return 1;
	}

	if (chdir(cwd) < 0) {
		fprintf(stderr, "chdir: %m\n");
		return 1;
	}

	setenv("SHELL", SHELL, 1);

	execv(SHELL, argv);

	// Not reached on success
	fprintf(stderr, "exec: %m\n");
	return 1;
}
