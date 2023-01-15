#!/bin/sh

set -e

editorconfig-checker .github contrib docs package scripts targets tests ./*.* .luacheckrc .editorconfig
