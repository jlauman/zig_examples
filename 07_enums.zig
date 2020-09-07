//! see: https://ziglang.org/documentation/master/#enum

// types
// enums may have methods (namespaced functions) likes structs.
const WarpCore = enum {
    Stop,
    Idle,
    Warp,
    Fail,

    pub fn isOk(self: WarpCore) bool {
        return self != WarpCore.Fail;
    }
};

// use extern enum for C ABI compatible enums.
const CrewmemberRank = extern enum {
    Admiral,
    Captain,
    Commander,
    Lieutenant,
    Ensign,
    MasterChief,
    Chief,
    Crewman,
};

// non-exhaustive enum
const SingleDigit = enum(u8) {
    One,
    Two,
    Three,
    _,
};

pub fn main() !void {
    const file_name = std.fs.path.basename(@src().file);
    print("\n  file: {}\n", .{file_name});
}

test "enum method" {
    const core = WarpCore.Idle;
    expect(core.isOk() == true);
}

test "enum variant switch" {
    const core = WarpCore.Fail;
    const display = switch (core) {
        WarpCore.Stop => "warp core is stopped.",
        WarpCore.Idle => "warp core is idle.",
        WarpCore.Warp => "warp core is at warp.",
        WarpCore.Fail => "warp core has failed.",
    };
    expect(eql(u8, display, "warp core has failed."));
}

test "enum literal" {
    const rank: CrewmemberRank = .Ensign;
    expect(rank == .Ensign);
}

test "enum with non-exhaustive switch" {
    const digit = SingleDigit.Two;
    const n = switch(digit) {
        .One => 1,
        .Two => 2,
        .Three => 3,
        _ => 0,
    };
    expect(n == 2);
}

// imports
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const eql = std.mem.eql;
