//! see: https://ziglang.org/documentation/master/#Zig-Test
//! see: https://ziglang.org/documentation/master/std/#builtin;is_test

// types
// may create an `extern union` to be C ABI compatible.
const Payload1 = union {
    Integer: i64,
    Float: f64,
    Boolean: bool,
};

// must created a tagged union to use switch
const Payload2Label = enum {
    Integer,
    Float,
    Boolean,
};

const Payload2 = union(Payload2Label) {
    Integer: i64,
    Float: f64,
    Boolean: bool,
};

pub fn main() !void {
    const file_name = std.fs.path.basename(@src().file);
    print("\n  file: {}\n", .{file_name});
}

// anonymous union literal syntax
fn makeBooleanPayload(b: bool) Payload1 {
    return .{ .Boolean = b };
}

test "union value" {
    var payload = Payload1{ .Integer = 42 };
    // will trigger access of inactive union field error
    // payload.Float = 42.42;
    expect(payload.Integer == 42);
}

test "anonymous union literal" {
    const payload = makeBooleanPayload(false);
    expect(payload.Boolean == false);
}

test "tagged union switch" {
    var payload = Payload2{ .Integer = 42 };
    expect(payload.Integer == 42);
    const str = switch (payload) {
        .Integer => "an integer",
        .Float => "a float",
        .Boolean => "a boolean",
    };
    expect(eql(u8, str, "an integer"));
}

// imports
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const eql = std.mem.eql;
