//! see: https://ziglang.org/documentation/master/#Top-Level-Doc-Comments
//! see: https://ziglang.org/documentation/master/#Global-Variables
//! see: https://ziglang.org/documentation/master/std/#std;fs.path

// global variables
var x: i32 = 42;

pub fn main() !void {
    const file_name = std.fs.path.basename(@src().file);
    print("\n  main: file={s}, x={d}\n", .{ file_name, x });
}

test "use expect for tests" {
    try main();
    expect(x == 42);
}

// imports
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
