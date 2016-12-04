#pragma once

struct iface_list {
	int ifx;
	int wiphy;
	struct iface_list *next;
};

struct iface_list *get_ifaces();
