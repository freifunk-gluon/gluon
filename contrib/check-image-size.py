#!/usr/bin/env python3

import argparse
import json
import sys
from enum import Enum

# Enum Class for checking image size
class ImageSizeCheck(Enum):
    OK = "OK"
    TOO_BIG = "TOO_BIG"
    IGNORED = "IGNORED"
    UNKNOWN = "UNKNOWN"


# Some devices pad their images to IMAGE_SIZE and apply a firmware header.
# Exclude this from the image size check.
excluded_devices = [
    "tplink_cpe210-v1",
    "tplink_cpe210-v2",
    "tplink_cpe210-v3",
    "tplink_cpe220-v3",
    "tplink_cpe510-v1",
    "tplink_cpe510-v2",
    "tplink_cpe510-v3",
    "tplink_cpe710-v1",
    "tplink_wbs210-v1",
    "tplink_wbs210-v2",
    "tplink_wbs510-v1"
]


def open_json(file_path):
    with open(file_path, 'r') as f:
        return json.load(f)


def load_openwrt_profile_json(json_path):
    profiles = []
    profile_json = open_json(json_path)
    for profile_name, profile_data in profile_json["profiles"].items():
        device_profile = {
            "name": profile_name,
        }
        if "image" in profile_data.get("file_size_limits", {}):
            device_profile["max_image_size"] = profile_data["file_size_limits"]["image"]

        for image in profile_data["images"]:
            if image["type"] != "sysupgrade":
                continue
            if "size" in image:
                device_profile["image_size"] = image["size"]
        
        profiles.append(device_profile)
    
    return profiles


def check_image_size_below_limit(profile, overhead=0):
    # Skip devices that pad their images
    if profile["name"] in excluded_devices:
        return ImageSizeCheck.IGNORED

    if "max_image_size" in profile and "image_size" in profile:
        if profile["image_size"] + (overhead * 1024) > profile["max_image_size"]:
            return ImageSizeCheck.TOO_BIG
        else:	
            return ImageSizeCheck.OK
    
    return ImageSizeCheck.UNKNOWN


def print_github_actions_warning(message):
    print('::warning::{}'.format(message))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Check image size of OpenWrt profiles')
    parser.add_argument(
        'profile_json',
        help='Path to profile.json',
        nargs='+'
    )
    parser.add_argument(
        '--github-actions',
        help='Generate warnings for use with GitHub Actions',
        action='store_true'
    )
    parser.add_argument(
        '--overhead',
        type=int,
        help='Additional size to add to the image size in kilobyte',
        default=0
    )
    args = parser.parse_args()

    if args.profile_json is None:
        print('Error: profile.json not specified')
        sys.exit(1)
    
    # Load all profile.json files
    profiles = []
    for profile_file in args.profile_json:
        profiles.extend(load_openwrt_profile_json(profile_file))

    # Initialize results with all available ImageSizeCheck values
    results = {}
    for check_result in ImageSizeCheck:
        results[check_result] = []

    for profile in profiles:
        check_result = check_image_size_below_limit(profile, args.overhead)
        results[check_result].append(profile)
    
    for check_result, profiles in results.items():
        if len(profiles) == 0:
            continue

        # Group by result type for GitHub Actions
        if args.github_actions:
            print('::group::{}'.format(check_result.value))

        for profile in profiles:
            if check_result == ImageSizeCheck.TOO_BIG:
                msg = 'Image size of profile {} is too big ({} > {})'.format(
                    profile["name"],
                    profile["image_size"] + (args.overhead * 1024),
                    profile["max_image_size"])
                if args.github_actions:
                    print_github_actions_warning(msg)
                else:
                    print("Warning: {}".format(msg))
            elif check_result == ImageSizeCheck.UNKNOWN:
                msg = 'Image size of profile {} is unknown'.format(
                    profile["name"])
                print(msg)
            elif check_result == ImageSizeCheck.IGNORED:
                msg = 'Image size of profile {} is ignored (Image size {})'.format(
                    profile["name"], profile.get("image_size", "unknown"))
                print(msg)
            else:
                msg = 'Image size of profile {} is OK ({} < {})'.format(
                    profile["name"], 
                    profile["image_size"] + (args.overhead * 1024),
                    profile["max_image_size"])
                print(msg)
