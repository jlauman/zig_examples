pub fn main() !void {
    var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer aa.deinit();
    var allocator = &aa.allocator;

    const file = try std.fs.cwd().createFile(
        "hello.txt",
        .{ .read = true },
    );
    defer file.close();
    try file.writeAll("hello, world!\n");

    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();
    try file.seekTo(0);
    try file.reader().readAllArrayList(&list, 16 * 1024);

    print("hello.text={}\n", .{list.items});
    expect(eql(u8, list.items, "hello, world!\n"));
}

// imports
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const eql = std.mem.eql;
