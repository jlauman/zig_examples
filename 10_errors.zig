//! https://ziglang.org/documentation/master/#Errors

// types
const WarpCoreFailError = error{
    CrystalDepleted,
    InjectorDamaged,
    CoreBreach,
};

pub fn main() !void {
    const file_name = std.fs.path.basename(@src().file);
    print("\n  file: {}\n", .{file_name});
}

fn startCore1() error{WarpCoreFailError}!bool {
    return true;
}

fn startCore2() WarpCoreFailError!bool {
    return WarpCoreFailError.InjectorDamaged;
}

test "function return value" {
    const ready = try startCore1();
    expect(ready == true);
}

test "function return error" {
    const ready = startCore2() catch |err| {
        expect(err == WarpCoreFailError.InjectorDamaged);
        return;
    };
    unreachable;
}

// imports
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
