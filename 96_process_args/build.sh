#!/usr/bin/env bash

zig build-exe example.zig &&\
  ./example -v --hello world
