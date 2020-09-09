// zig build-exe example.zig

pub fn main() !void {
    const file_name = std.fs.path.basename(@src().file);
    print("\n  file: {}\n", .{file_name});
    var buffer: [128]u8 = undefined;
    while (true) {
        var input = readStdIn(buffer[0..]) catch |err| {
            if (err == error.StreamTooLong) {
                print("string too long...\n", .{});
                continue;
            }
            return err;
        };
        if (eql(u8, input.?, "quit")) {
            return;
        } else {
            print("input=\"{}\"\n", .{input});
        }
    }
}

fn readStdIn(buffer: []u8) !?[]u8 {
    const stdin = std.io.getStdIn().inStream();
    print("what?> ", .{});
    const slice = stdin.readUntilDelimiterOrEof(buffer, '\n') catch |err| {
        if (err == error.StreamTooLong) {
            // consume remainder stdin to newline
            try stdin.skipUntilDelimiterOrEof('\n');
        }
        return err;
    };
    return slice;
}

// imports
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const eql = std.mem.eql;
