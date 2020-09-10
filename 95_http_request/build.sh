#!/usr/bin/env bash

ZIG_VERSION=$(zig version)

echo "pub fn version() []const u8 { return \""$ZIG_VERSION"\"; }"> version.zig

zig build-exe example.zig
