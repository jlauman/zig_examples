const std = @import("std");
const bprint = std.fmt.bufPrint;

// will create correct allocator if wasm target
var A = std.heap.page_allocator;

var js_print_buf = [_]u8{0} ** 128;
extern fn js_print(u32, usize) void;

export fn newUint8Array(len: usize) u32 {
    var buf = A.alloc(u8, len) catch |err| return 0;
    return @ptrToInt(buf.ptr);
}

fn print(comptime fmt: []const u8, data: anytype) void {
    var buf1 = js_print_buf[0..];
    var i: u32 = 0;
    while (i < buf1.len) : (i += 1) buf1[i] = 0;
    var buf2 = bprint(buf1, fmt, data) catch unreachable;
    var len = @intCast(u32, std.fmt.count(fmt, data));
    js_print(@ptrToInt(buf2.ptr), len);
}

export fn count(stra: [*]const u8, strc: usize) i32 {
    print("count={}", .{strc});
    const str = stra[0..strc];
    const len = str.len;
    return @intCast(i32, len);
}

export fn getHello(stra: [*]u8, strc: usize) u32 {
    print("getHello={}", .{strc});
    var buf1 = stra[0..strc];
    var i: usize = 0;
    while (i < buf1.len) : (i += 1) buf1[i] = 0;
    var buf2 = bprint(buf1, "{}", .{"goodbye!"}) catch |err| return 0;
    return buf2.len;
}
