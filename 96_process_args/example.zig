// usage: ./example -v --hello world

pub fn main() !void {
    print("test std.process.argsAlloc\n", .{});
    // var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer aa.deinit();
    // var allocator = &aa.allocator;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    defer if (gpa.deinit()) std.os.exit(1);

    const args = try std.process.argsAlloc(allocator);
    // comment the next line to trigger memory leak detection
    defer std.process.argsFree(allocator, args);

    for (args) |arg, index| {
        print("arg[{}]={}\n", .{ index, arg });
        if (index == 0) expect(eql(u8, arg, "./example"));
        if (index == 1) expect(eql(u8, arg, "-v"));
        if (index == 2) expect(eql(u8, arg, "--hello"));
        if (index == 3) expect(eql(u8, arg, "world"));
    }
}

// imports
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const eql = std.mem.eql;
