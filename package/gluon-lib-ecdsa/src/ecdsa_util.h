#include <ecdsautil/ecdsa.h>
#include <ecdsautil/sha256.h>

struct verify_params {
	const char* data;

	size_t n_signatures;
	ecdsa_signature_t **signatures;

	size_t n_pubkeys;
	ecc_25519_work_t *pubkeys;

	unsigned long good_signatures;
};

bool do_verify(struct verify_params* params);
int load_pubkeys(struct verify_params* params, const size_t n_pubkeys, const char **pubkeys_str, const bool ignore_pubkeys);
int load_signatures(struct verify_params* params, const size_t n_signatures, const char **signatures_str, const bool ignore_signatures);
