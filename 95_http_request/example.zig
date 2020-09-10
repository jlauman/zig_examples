pub fn main() !void {
    print("http get google.com...\n", .{});
    var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer aa.deinit();
    var allocator = &aa.allocator;

    try network.init();
    defer network.deinit();

    // const endpoint_list = try network.getEndpointList(allocator, "localhost", 41829);
    // // const endpoint_list = try network.getEndpointList(allocator, "google.com", 80);
    // defer endpoint_list.deinit();
    // print("endpoints...\n", .{});
    // var endpoint: network.EndPoint = endpoint_list.endpoints[1];
    // for (endpoint_list.endpoints) |ep| {
    //     print("  {}\n", .{ep});
    // }

    const sock = try network.connectToHost(allocator, "google.com", 80, .tcp);
    // var sock = try network.Socket.create(.ipv4, .tcp);
    // try sock.connect(endpoint);
    defer sock.close();

    const lines = [_][]const u8{
        "GET / HTTP/1.1",
        "Host: google.com",
        "User-Agent: Zig/" ++ compiler.version(),
        "Accept: text/html; charset=UTF-8",
        "Connection: close",
        "\r\n",
    }; // extra crlf required to end headers
    const request = try std.mem.join(allocator, "\r\n", &lines);
    defer allocator.free(request);
    print("request...\n{}", .{request});
    _ = try sock.send(request);
    // try sock.writer().writeAll(request);

    // doesn't work... never reads?!? does this require an event?
    // var response = std.ArrayList(u8).init(allocator);
    // defer response.deinit();
    // try sock.reader().readAllArrayList(&response, 16 * 1024);

    // perform blocking read on socket
    var buffer = try allocator.alloc(u8, 1024);
    defer allocator.free(buffer);
    const bytes_read = try sock.receive(buffer);
    const response = buffer[0..bytes_read];
    print("response...\n{}", .{response});
}

// imports
const std = @import("std");
const print = std.debug.print;
const network = @import("20200909_zig-network.zig");
const compiler = @import("version.zig");
