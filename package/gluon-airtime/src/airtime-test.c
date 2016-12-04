#include <stdio.h>
#include "airtime.h"

void print_result(struct airtime_result *);

int main(int argc, char *argv[]) {
	struct airtime *a;

	if (argc != 3) {
		fprintf(stderr,"Usage: %s <wifi1> <wifi2>\n", argv[0]);
		return 1;
	}

	a = get_airtime(argv[1], argv[2]);
	print_result(&a->radio0);
	print_result(&a->radio1);
}

void print_result(struct airtime_result *result){
	printf("freq=%d\tnoise=%d\tbusy=%lld\tactive=%lld\trx=%lld\ttx=%lld\n",
		result->frequency,
		result->noise,
		result->busy_time,
		result->active_time,
		result->rx_time,
		result->tx_time
	);
}
