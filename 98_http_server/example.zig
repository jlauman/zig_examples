const is_linux = comptime std.Target.current.os.tag == .linux;

pub const io_mode = .evented;

var server: network.Socket = undefined;

pub fn main() !void {
    print("http server...\n", .{});
    // var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer aa.deinit();
    // var allocator = &aa.allocator;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    defer if (gpa.deinit()) std.os.exit(1);

    if (is_linux) {
        const actionSigint = std.os.Sigaction{
            .sigaction = handleSigintLinux,
            .mask = std.os.empty_sigset,
            .flags = 0,
        };
        std.os.sigaction(std.os.SIGINT, &actionSigint, null);
    }

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var port: u16 = 8080;

    var lastFlag: []const u8 = undefined;
    for (args) |arg, index| {
        if (startsWith(u8, arg, "-")) {
            lastFlag = arg;
        } else if (eql(u8, lastFlag, "--port")) {
            port = try std.fmt.parseUnsigned(u16, arg, 10);
        }
    }

    print("  port={}\n", .{port});

    try network.init();
    defer network.deinit();

    server = try network.Socket.create(.ipv4, .tcp);
    defer server.close();

    try server.bind(.{
        .address = .{ .ipv4 = network.Address.IPv4.any },
        .port = port,
    });

    try server.listen();
    print("listening on {}\n", .{try server.getLocalEndPoint()});
    while (true) {
        print("waiting for connection...\n", .{});
        const socket = try server.accept();
        const client = try allocator.create(Client);
        client.* = Client{
            .allocator = allocator,
            .socket = socket,
            .handle_frame = async client.handle(),
        };
    }
}

fn handleSigintLinux(sig: i32, info: *const std.os.siginfo_t, ctx_ptr: ?*const c_void) callconv(.C) void {
    print("\nhandleSigintLinux!\n", .{});
    server.close();
    std.os.exit(0);
}

const Client = struct {
    allocator: *Allocator,
    socket: network.Socket,
    handle_frame: @Frame(Client.handle),

    fn handle(self: *Client) !void {
        var list = std.ArrayList(u8).init(self.allocator);
        defer list.deinit();
        while (true) {
            const bufferSize: u32 = 1024;
            var buffer: [bufferSize]u8 = undefined;
            // this is a blocking read...
            // when count is less than buffer size (or 0) read is complete.
            // FIXME: receive will never return 0 after a bufferSize read!!!
            // FIXME: use curl http://127.0.0.1:8080 to get size of request and change bufferSize
            const count = try self.socket.receive(&buffer);
            // print("received: count={}\n", .{count});
            try list.appendSlice(buffer[0..count]);
            if (count < bufferSize) break;
        }
        const request = list.items[0..];
        // print("request.len={}\n", .{request.len});
        // print("request is {}\n", .{@typeName(@TypeOf(request))});
        print("received...\n{}", .{request});

        var buffer2: [256]u8 = undefined;
        const path = try parsePath(&buffer2, request);
        print("\npath={}\n", .{path});

        var content: []const u8 = undefined;
        var response: []const u8 = undefined;
        if (eql(u8, path, "/favicon.ico")) {
            content = try getFavicon(self.allocator);
            response = try makeResponse(self.allocator, "200 OK", "image/png", content);
        } else if (eql(u8, path, "/")) {
            content = try get302Html(self.allocator);
            response = try makeResponse(self.allocator, "302 FOUND", "text/html", content);
        } else if (eql(u8, path, "/index.html")) {
            content = try getIndexHtml(self.allocator);
            response = try makeResponse(self.allocator, "200 OK", "text/html", content);
        } else if (eql(u8, path, "/index.css")) {
            content = try getIndexCss(self.allocator);
            response = try makeResponse(self.allocator, "200 OK", "text/css", content);
        } else {
            content = try get404Html(self.allocator);
            response = try makeResponse(self.allocator, "404 NOT FOUND", "text/html", content);
        }
        defer self.allocator.free(content);
        defer self.allocator.free(response);

        // print("\nsending...\n{}", .{response});
        _ = try self.socket.send(response);

        self.socket.close();
    }
};

fn parsePath(buffer: []u8, request: []u8) ![]u8 {
    const idx1 = std.mem.indexOfScalar(u8, request, ' ') orelse return error.Failure;
    const idx2 = std.mem.indexOfScalarPos(u8, request, idx1 + 1, ' ') orelse return error.Failure;
    // print("parsePath: idx1={}, idx2={}\n", .{ idx1, idx2 });
    // std.mem.secureZero(u8, buffer);
    std.mem.copy(u8, buffer, request[(idx1 + 1)..idx2]);
    const path = buffer[0..(idx2 - (idx1 + 1))];
    // print("parsePath: path={}\n", .{path});
    return path;
}

fn makeResponse(allocator: *Allocator, code: []const u8, mimeType: []const u8, content: []const u8) ![]const u8 {
    const aprint = std.fmt.allocPrint;
    var ts = try timestamp.Timestamp.now();
    const header1 = try aprint(allocator, "HTTP/1.1 {}", .{code});
    defer allocator.free(header1);
    // const header2 = try aprint(allocator, "Date: {}", .{std.time.milliTimestamp()});
    var header2buf: [32]u8 = undefined;
    const header2 = try aprint(allocator, "Date: {}", .{ts.asctime(header2buf[0..])});
    defer allocator.free(header2);
    const header3 = try aprint(allocator, "Content-Type: {}", .{mimeType});
    defer allocator.free(header3);
    const header4 = try aprint(allocator, "Content-Length: {}", .{content.len});
    defer allocator.free(header4);
    if (startsWith(u8, code, "302 ")) {
        const header5 = try aprint(allocator, "Location: /index.html", .{});
        defer allocator.free(header5);
        const lines = &[_][]const u8{
            header1,
            "Server: zig/" ++ compiler.version(),
            header2,
            header3,
            header4,
            header5,
            "Connection: close",
            "",
            content,
        };
        return try std.mem.join(allocator, "\r\n", lines);
    } else {
        const lines = &[_][]const u8{
            header1,
            "Server: zig/" ++ compiler.version(),
            header2,
            header3,
            header4,
            "Connection: close",
            "",
            content,
        };
        return try std.mem.join(allocator, "\r\n", lines);
    }
}

fn get302Html(allocator: *Allocator) ![]const u8 {
    const template =
        \\<html>
        \\<head>
        \\  <title>302 Found</title>
        \\</head>
        \\<body bgcolor="white">
        \\  <center><h1>302 Found</h1></center>
        \\  <hr>
        \\  <center>Zig/{}</center>
        \\  <center><a href="/index.html">index.html</a></center>
        \\</body>
        \\</html>
    ; // end string
    const html = std.fmt.allocPrint(allocator, template, .{compiler.version()});
    return html;
}

fn get404Html(allocator: *Allocator) ![]const u8 {
    const template =
        \\<html>
        \\<head>
        \\  <title>404 Not Found</title>
        \\</head>
        \\<body bgcolor="white">
        \\  <center><h1>404 Not Found</h1></center>
        \\  <hr>
        \\  <center>Zig/{}</center>
        \\</body>
        \\</html>
    ; // end string
    const html = std.fmt.allocPrint(allocator, template, .{compiler.version()});
    return html;
}

fn getFavicon(allocator: *Allocator) ![]const u8 {
    const bytes = @embedFile("./web/dragon.png");
    // @compileLog(bytes);
    const content = try allocator.alloc(u8, bytes.len);
    std.mem.copy(u8, content, bytes);
    return content;
}

fn getIndexHtml(allocator: *Allocator) ![]const u8 {
    const bytes = @embedFile("./web/index.html");
    // @compileLog(bytes);
    const content = try allocator.alloc(u8, bytes.len);
    std.mem.copy(u8, content, bytes);
    return content;
}

fn getIndexCss(allocator: *Allocator) ![]const u8 {
    const bytes = @embedFile("./web/index.css");
    // @compileLog(bytes);
    const content = try allocator.alloc(u8, bytes.len);
    std.mem.copy(u8, content, bytes);
    return content;
}

// imports
const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const eql = std.mem.eql;
const startsWith = std.mem.startsWith;
const network = @import("20200909_zig-network.zig");
const compiler = @import("version.zig");
const timestamp = @import("timestamp.zig");
