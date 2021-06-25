#!/bin/sh

set -e

ec .github contrib docs package scripts targets tests ./*.* .luacheckrc .editorconfig .ecrc
