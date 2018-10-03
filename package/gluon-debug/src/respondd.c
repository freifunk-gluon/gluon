/*
  Copyright (c) 2016, Leonardo Mörlein <git@irrelefant.net>
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice,
       this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright notice,
       this list of conditions and the following disclaimer in the documentation
       and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include <errno.h>
#include <respondd.h>
#include <glob.h>
#include "json-c/json.h"
#include <libgluonutil.h>

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>


#include <sys/vfs.h>

static struct json_object * respondd_provider_statistics(void) {
	struct json_object *proc = json_object_new_object();

	glob_t globbuf;
	int ret = glob("/proc/[0-9]*/stat", 0, NULL, &globbuf);
	if (ret != 0)
	  // we don't really care about the reason and simply return {}
		goto end;

	for(int i=0; i < globbuf.gl_pathc; i++) {
		FILE* f = fopen(globbuf.gl_pathv[i], "r");
		if (!f)
			continue;

		int pid = 0;
		unsigned long utime = 0;
		unsigned long stime = 0;
		long cutime = 0;
		long cstime = 0;

		char name[64];

		int cnt = fscanf(f, "%d %63s "
		                    "%*c "
		                    "%*d %*d %*d %*d %*d "
		                    "%*u %*u %*u %*u %*u "
		                    "%lu %lu %ld %ld",
		                    &pid, name, &utime, &stime, &cutime, &cstime);
		if (cnt != 6)
			goto next;

		struct json_object *process = json_object_new_object();

		json_object_object_add(process, "name", gluonutil_wrap_string(name));
		json_object_object_add(process, "utime", json_object_new_int(utime));
		json_object_object_add(process, "stime", json_object_new_int(stime));
		json_object_object_add(process, "cutime", json_object_new_int(cutime));
		json_object_object_add(process, "cstime", json_object_new_int(cstime));

		char pidstr[8];
		snprintf(pidstr, 7, "%d", pid);
		json_object_object_add(proc, pidstr, process);

	next:
		fclose(f);

		// Normally this should fit in 1280 bytes (compressed).
		// - Otherwise it will be fragmented.
		if(i>80)
			break;
	}

end:
	globfree(&globbuf);
	return proc;
}

const struct respondd_provider_info respondd_providers[] = {
	{"proc", respondd_provider_statistics},
	{}
};
