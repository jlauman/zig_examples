#!/usr/bin/env bash

zig build-exe example.zig -I/usr/include -I/usr/include/x86_64-linux-gnu/ -lc -lreadline

