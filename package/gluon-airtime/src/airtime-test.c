#include <stdio.h>
#include <stdlib.h>
#include "airtime.h"
#include "ifaces.h"

void print_result(struct airtime_result *);

int main(int argc, char *argv[]) {
	struct airtime_result a;
	struct iface_list *ifaces;
	void *freeptr;

	ifaces = get_ifaces();
	while (ifaces != NULL) {
		get_airtime(&a, ifaces->ifx);
		print_result(&a);
		freeptr = ifaces;
		ifaces = ifaces->next;
		free(freeptr);
	}
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
