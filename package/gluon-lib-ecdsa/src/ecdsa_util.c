#include "ecdsa_util.h"
#include "hexutil.h"
#include "util.h"

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <limits.h>

bool do_verify(struct verify_params* params) {
	ecdsa_verify_context_t ctxs[params->n_signatures];
	for (size_t i = 0; i < params->n_signatures; i++)
		ecdsa_verify_prepare_legacy(&ctxs[i], &params->hash, &params->signatures[i]);

	long unsigned int good_signatures = ecdsa_verify_list_legacy(ctxs, params->n_signatures, params->pubkeys, params->n_pubkeys);

	if (good_signatures < params->good_signatures) {
		return false;
	}

	return true;
}

int hash_data(struct verify_params* params, const char* data) {
  ecdsa_sha256_context_t hash_ctx;
  ecdsa_sha256_init(&hash_ctx);
  ecdsa_sha256_update(&hash_ctx, data, strlen(data));

  ecdsa_sha256_final(&hash_ctx, params->hash.p);

  return 1;
}

int load_pubkeys(struct verify_params* params, const size_t n_pubkeys, const char **pubkeys_str, const bool ignore_pubkeys) {
  params->pubkeys = safe_malloc(n_pubkeys * sizeof(ecc_25519_work_t));

	size_t ignored_keys = 0;

	for (size_t i = 0; i < n_pubkeys; i++) {
		ecc_int256_t pubkey_packed;
		if (!pubkeys_str[i])
			goto pubkey_fail;
		if (!parsehex(pubkey_packed.p, pubkeys_str[i], 32))
			goto pubkey_fail;
		if (!ecc_25519_load_packed_legacy(&params->pubkeys[i-ignored_keys], &pubkey_packed))
			goto pubkey_fail;
		if (!ecdsa_is_valid_pubkey(&params->pubkeys[i-ignored_keys]))
			goto pubkey_fail;
		continue;

pubkey_fail:
		if (ignore_pubkeys) {
			fprintf(stderr, "warning: ignoring invalid public key %s\n", pubkeys_str[i]);
			ignored_keys++;
		} else {
			return 0;
		}
	}

	params->n_pubkeys = n_pubkeys - ignored_keys;

	return 1;
}

int load_signatures(struct verify_params* params, const size_t n_signatures, const char **signatures_str, const bool ignore_signatures) {
	params->signatures = safe_malloc(n_signatures * sizeof(ecdsa_signature_t));

  size_t ignored_signatures = 0;

	for (size_t i = 0; i < n_signatures; i++) {
		if (!signatures_str[i])
			goto signature_fail;
		if (!parsehex(&params->signatures[i-ignored_signatures], signatures_str[i], 64))
			goto signature_fail;
		continue;

signature_fail:
		if (ignore_signatures) {
			fprintf(stderr, "warning: ignoring invalid signature %s\n", signatures_str[i]);
			ignored_signatures++;
		} else {
			return 0;
		}
	}

	params->n_signatures = n_signatures - ignored_signatures;

	return 1;
}
