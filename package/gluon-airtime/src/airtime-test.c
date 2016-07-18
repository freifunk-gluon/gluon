#include <stdio.h>
#include <unistd.h> /* sleep */
#include "airtime.h"

void print_result(struct airtime_result *);

int main(int argc, char *argv[]) {
	struct airtime *a;

	if (argc != 3) {
		fprintf(stderr,"Usage: %s <wifi1> <wifi2>\n", argv[0]);
		return 1;
	}

	while (1) {
		a = get_airtime(argv[1], argv[2]);
		print_result(&a->radio0);
		print_result(&a->radio1);
		sleep(1);
	}
}

void print_result(struct airtime_result *result){
	printf("freq=%d\tnoise=%d\tbusy=%lld\tactive=%lld\trx=%lld\ttx=%lld\n",
		result->frequency,
		result->noise,
		result->busy_time.current,
		result->active_time.current,
		result->rx_time.current,
		result->tx_time.current
	);
}
