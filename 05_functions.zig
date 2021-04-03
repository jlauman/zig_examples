//! see:

pub fn main() !void {
    const file_name = std.fs.path.basename(@src().file);
    print("\n  file: {}\n", .{file_name});
}

// basic function that takes two arguments and returns a primitive values.
// this function does not return an error, but may trigger a runtime integer
// overflow error.
fn add(a: i8, b: i8) i8 {
    if (a == 0) {
        return b;
    }
    return a + b;
}

// pub makes the function visible for zig @import. primitive argument
// types are passed by value. parameters are immutable.
// see: https://ziglang.org/documentation/master/#Pass-by-value-Parameters
pub fn sub(a: i8, b: i8) i8 {
    return a - b;
}

// export makes the function visible outside the generated object file
// for link time resolution and generates C ABI format.
export fn mul(a: i8, b: i8) i8 {
    return a * b;
}

// inline forces a function to inline at all call sites. when it cannot
// be inlined an error is thrown at compile time.
fn div(a: i8, b: i8) callconv(.Inline) i8 {
    return @divExact(a, b);
}

// the return type prefixed with '!' means 'anyerror!i8'. anyerror is a super
// type of all errors. see `Hello World` comments on error set types.
// see: https://ziglang.org/documentation/master/#Hello-World
// see: https://ziglang.org/documentation/master/#Error-Set-Type
fn add3(a: i8) error{Overflow}!i8 {
    var x: i8 = 3;
    if (@addWithOverflow(i8, x, a, &x)) {
        return error.Overflow;
    }
    return x;
}

test "function add i8" {
    // 128 is runtime integer overflow for i8
    expect(add(100, 27) == 127);
}

test "function sub i8" {
    expect(sub(127, 100) == 27);
}

test "function mul i8" {
    expect(mul(62, 2) == 124);
}

test "function div i8" {
    expect(div(124, 2) == 62);
}

// see: https://ziglang.org/documentation/master/#try
// see: https://ziglang.org/documentation/master/#unreachable
test "funciton add8 with return error" {
    const n1 = try add3(124);
    const n2 = add3(127) catch |err| {
        expect(err == error.Overflow);
        return;
    };
    unreachable;
}

// imports
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
