#include <respondd.h>
#include <json-c/json.h>
#include <libgluonutil.h>
#include <uci.h>
#include <string.h>
#include <net/if.h>

#define _STRINGIFY(s) #s
#define STRINGIFY(s) _STRINGIFY(s)

bool strstw(const char *pre, const char *str) {
	size_t lenpre = strlen(pre);
	return strlen(str) < lenpre ? false : strncmp(pre, str, lenpre) == 0;
}

bool strrmbs(char *line, int begin, int end) { // <- ist es hier sinvoller pointer auf die ints zu setzen??
	size_t len = strlen(line);
	if (len < begin)
		return false;

	memmove(line, line+begin, len - begin + 1);
	if (len < end)
		return false;

	line[len-end] = 0; //remove val of end characters on the end
	return true;
}

// extract hood informations
static struct json_object * get_hoodselector(void) {
	FILE *f = fopen("/tmp/.hoodselector", "r");
	if (!f)
		return NULL;

	struct json_object *ret = json_object_new_object();
	char *line = NULL;
	size_t len = 0;
	while (getline(&line, &len, f) >= 0) {
		//1. Get md5 hash from current selected hood.
		if (strstw("\"md5hash\": ",line)) {
			if (!strrmbs(line, 12, 14))
				continue;

			json_object_object_add(ret, "md5hash", gluonutil_wrap_string(line));
		}
		//2. Get true or false string for VPN Router.
		if (strstw("\"vpnrouter\": ",line)) {
			if (!strrmbs(line, 14, 16))
				continue;

			json_object_object_add(ret, "vpnrouter", gluonutil_wrap_string(line));
		}
		//3. Get hoodname
		if (strstw("\"hoodname\": ",line)) {
			if (!strrmbs(line, 13, 15))
				continue;

			json_object_object_add(ret, "hoodname", gluonutil_wrap_string(line));
		}
	}
	free(line);
	fclose(f);
	return ret;
}

//Get currend selected BSSID
static struct json_object * get_current_selected_bssid(void){
	struct uci_context *ctx = uci_alloc_context();
	ctx->flags &= ~UCI_FLAG_STRICT;
	struct uci_package *p;

	if (uci_load(ctx, "wireless", &p))
		goto end;

	struct uci_element *e;
	uci_foreach_element(&p->sections, e) {
		struct uci_section *s = uci_to_section(e);
		if (strcmp(s->type, "wifi-iface"))
			continue;

		if (strncmp(e->name, "ibss_", 5))
			continue;

		const char *bssid = uci_lookup_option_string(ctx, s, "bssid");
		if (!bssid)
			continue;

		struct json_object *ret = json_object_new_object();
		json_object_object_add(ret, "bssid", gluonutil_wrap_string(bssid));
		free(bssid);
		uci_free_context(ctx);
		return ret;
	}
end:
	uci_free_context(ctx);
	return NULL;
}


// create final obj with logical structure
static struct json_object * respondd_provider_hoodselector(void) {
	struct json_object *ret = json_object_new_object();

	struct json_object *hoodinfo = get_hoodselector();
	if(hoodinfo)
		json_object_object_add(ret, "hoodinfo", hoodinfo);

	struct json_object *selectedbssid = get_current_selected_bssid();
	if(selectedbssid)
		json_object_object_add(ret, "selectedbssid", selectedbssid);

	return ret;
}

// related to respondd_provider_hoodselector
const struct respondd_provider_info respondd_providers[] = {
	{"hoodselector", respondd_provider_hoodselector},
	{}
};
