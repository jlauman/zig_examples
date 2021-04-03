//! see: https://ziglang.org/documentation/master/#Primitive-Types
//! see: https://ziglang.org/documentation/master/#String-Literals-and-Character-Literals
//! see: https://ziglang.org/documentation/master/#TypeOf
//! see: https://ziglang.org/documentation/master/#typeName

// global variables
var x: i32 = 42;
var b: bool = true;
var s: []const u8 = "hello";

pub fn main() !void {
    const file_name = std.fs.path.basename(@src().file);
    print("\n  file: {}\n", .{file_name});
}

test "primitive type i32" {
    expect(x == 42);
    expect(@TypeOf(x) == i32);
    expect(eql(u8, @typeName(@TypeOf(x)), "i32"));
    print("  @TypeOf x is {s}\n", .{@typeName(@TypeOf(x))});
}

test "primitive type bool" {
    expect(b == true);
    expect(@TypeOf(b) == bool);
    expect(eql(u8, @typeName(@TypeOf(b)), "bool"));
    print("  @TypeOf b is {s}\n", .{@typeName(@TypeOf(b))});
}

test "string literal type []const u8" {
    expect(eql(u8, s, "hello"));
    expect(@TypeOf(s) == []const u8);
    expect(eql(u8, @typeName(@TypeOf(s)), "[]const u8"));
    print("  @TypeOf s is {s}\n", .{@typeName(@TypeOf(s))});
}

// imports
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const eql = std.mem.eql;
