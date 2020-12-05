const std = @import("std");
const network = @import("network.zig");

pub const io_mode = .evented;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    try network.init();
    defer network.deinit();

    var server = try network.Socket.create(.ipv4, .tcp);
    defer server.close();

    try server.bind(.{
        .address = .{ .ipv4 = network.Address.IPv4.any },
        .port = 2501,
    });

    try server.listen();
    std.debug.warn("listening at {}\n", .{try server.getLocalEndPoint()});
    while (true) {
        std.debug.print("Waiting for connection\n", .{});
        const client = try allocator.create(Client);
        client.* = Client{
            .conn = try server.accept(),
            .handle_frame = async client.handle(),
        };
    }
}

const Client = struct {
    conn: network.Socket,
    handle_frame: @Frame(Client.handle),

    fn handle(self: *Client) !void {
        //try self.conn.writer().writeAll("server: welcome to the chat server\n");
        const the404 =
            \\HTTP/1.1 404 Not Found
            \\Server: nginx/0.8.54
            \\Date: Mon, 02 Jan 2012 02:33:17 GMT
            \\Content-Type: text/html
            \\Content-Length: 169
            \\Connection: keep-alive
            \\
            \\<html>
            \\<head><title>404 Not Found</title></head>
            \\<body bgcolor="white">
            \\<center><h1>404 Not Found</h1></center>
            \\<hr><center>nginx/0.8.54</center>
            \\</body>
            \\</html>
            ; // end

        while (true) {
            var buf: [1024]u8 = undefined;
            const amt = try self.conn.receive(&buf);
            if (amt == 0)
                break; // We're done, end of connection
            const msg = buf[0..amt];
            std.debug.print("Client wrote...\n{}", .{msg});

            try self.conn.writer().writeAll(the404);
            break;
        }
        std.os.nanosleep(1, 0);
        self.conn.close();
    }
};
