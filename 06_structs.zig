//! see: https://ziglang.org/documentation/master/#Anonymous-List-Literals
//! see: https://ziglang.org/documentation/master/#struct

// types
const Starship1 = struct {
    name: []const u8,
    number: u32,
};

// structs with functions behave like methods (namespaced functions).
const Starship2 = struct {
    name: []const u8,
    number: u32,

    pub fn isSimulation(self: Starship2) bool {
        return eql(u8, self.name, "Kobayashi Maru");
    }
};

// extern struct should only be used for C ABI compatibility.
// see: https://ziglang.org/documentation/master/#extern-struct
const Starship3 = extern struct {
    name: []const u8,
    number: u32,
};

pub fn main() !void {
    const file_name = std.fs.path.basename(@src().file);
    print("\n  file: {}\n", .{file_name});
}

// anonymous list literals look like structs without field names.
// anonymous list literals are passed as arguments for `print` which
// accept an `anytype` and perform comptime/runtime logic.
test "anonymous list literal" {
    const list = .{ 1, 2, 3 };
    print(" @TypeOf(list) is {}\n", .{@typeName(@TypeOf(list))});
    expect(list[2] == 3);
}

test "anonymous struct" {
    const stct = .{ .a = "one", .b = 1 };
    print(" @TypeOf(stct) is {}\n", .{@typeName(@TypeOf(stct))});
    expect(eql(u8, stct.a, "one"));
}

test "struct Starship" {
    const ship = Starship1{
        .name = "Enterprise",
        .number = 1701,
    };
    print("  ship: {}\n", .{ship});
}

test "coerced struct Starship" {
    const ship: Starship1 = .{
        .name = "Yamato",
        .number = 24383,
    };
    print("  ship: {}\n", .{ship});
}

test "struct with methods (namespaced functions)" {
    const ship = Starship2{
        .name = "Kobayashi Maru",
        .number = 1022,
    };
    print("  ship: {}\n", .{ship});
    expect(ship.isSimulation() == true);
}

// imports
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const eql = std.mem.eql;
