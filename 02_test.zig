//! see: https://ziglang.org/documentation/master/#Zig-Test
//! see: https://ziglang.org/documentation/master/std/#builtin;is_test

// global variables
var x: i32 = 42;

pub fn main() !void {
    const file_name = std.fs.path.basename(@src().file);
    print("\n  file: {}\n", .{file_name});
}

test "std.builtin.is_test" {
    expect(std.builtin.is_test);
    expect(x == 42);
    print("  x == {}\n", .{x});
}

// imports
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
