//! see: https://ziglang.org/documentation/master/#Optionals

pub fn main() !void {
    const file_name = std.fs.path.basename(@src().file);
    print("\n  file: {}\n", .{file_name});
}

test "optional if test" {
    var x: ?u8 = null;
    x = 127;
    if (x) |_x| {
        expect(_x == 127);
        return;
    }
    unreachable;
}

test "optional orelse test" {
    var x: ?u8 = null;
    var y = x orelse 0;
    expect(y == 0);
}

test "optional orelse unreachable" {
    var x: ?u8 = 1;
    var y = x.?; // .? is 'orelse unreachable';
    expect(y == 1);
}

// imports
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
