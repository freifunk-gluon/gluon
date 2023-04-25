// SPDX-FileCopyrightText: 2022 Jan-Niklas Burfeind <gluon@aiyionpri.me>
// SPDX-License-Identifier: BSD-2-Clause
// SPDX-FileContributor: read_hex() by Matthias Schiffer <mschiffer@universe-factory.net>

#include <libubox/utils.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * how many blocks should be encoded at once - can be configured
 */
#define BLOCK_AMOUNT 32

/**
 * smallest possible block size to encode in b64 without further contex
 * is three bytes - do not change
 */
#define CHUNK_SIZE (3*BLOCK_AMOUNT)

/** print usage info and exit as failed */
static void usage(void) {
	fprintf(stderr, "Usage: gluon-hex-to-b64\n");
	exit(1);
}

/**
 * read a string of hexadecimal characters and return them as bytes
 * return false in case any non-hexadecimal characters are provided
 * return true on success
 */
static bool read_hex(uint8_t key[CHUNK_SIZE], const char *hexstr) {
	if (strspn(hexstr, "0123456789abcdefABCDEF") != strlen(hexstr))
		return false;

	size_t i;
	for (i = 0; i < CHUNK_SIZE; i++)
		sscanf(&hexstr[2 * i], "%02hhx", &key[i]);

	return true;
}

int main(int argc, char *argv[]) {
	if (argc != 1)
		usage();

	unsigned char hex_input[CHUNK_SIZE * 2 + 1];
	uint8_t as_bytes[CHUNK_SIZE];
	int byte_count;
	int b64_buflen = B64_ENCODE_LEN(CHUNK_SIZE);
	int b64_return;
	size_t ret;

	char str[b64_buflen];

	do {
		ret = fread(hex_input, 1, sizeof(hex_input) - 1, stdin);
		hex_input[ret] = '\0';

		/* in case fread did not fill six characters */
		if (ret != sizeof(hex_input)-1) {
			/* drop newline by replacing it with a null character */
			hex_input[strcspn(hex_input, "\n")] = 0;

			/*
			 * count length of resulting string and make sure it's even,
			 * as bytes are represented using pairs of hex characters
			 */
			ret = strlen(hex_input);
			if (ret % 2 == 1) {
				fprintf(stderr, "Error: Incomplete hex representation of a byte.\n");
				exit(EXIT_FAILURE);
			}
		}

		byte_count = ret / 2;
		b64_buflen = B64_ENCODE_LEN(byte_count);

		/* in case read_hex fails due to invalid characters */
		if (!read_hex(as_bytes, hex_input)) {
			fprintf(stderr, "Error: Invalid hexadecimal input.\n");
			exit(EXIT_FAILURE);
		}

		b64_return = b64_encode(as_bytes, byte_count, str, b64_buflen);

		/* trailing '\0' is not counted by b64_encode(), so we subtract one character */
		if (b64_buflen - 1 != b64_return) {
			fprintf(stderr, "Error: Encoding bytes as b64 failed.\n");
			exit(EXIT_FAILURE);
		}

		printf("%s", str);
	/* repeat until a non full block is read */
	} while (ret == sizeof(hex_input)-1);
	printf("\n");

	exit(EXIT_SUCCESS);
}
