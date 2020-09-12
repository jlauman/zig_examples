const is_linux = comptime std.Target.current.os.tag == .linux;

pub fn main() !void {
    print("98_os!\n", .{});

    var buffer: [256]u8 = undefined;
    const cwd = try std.os.getcwd(buffer[0..]);
    print("cwd={}\n", .{cwd});

    const path = std.os.getenv("HOME");
    print("path={}\n", .{path.?});

    if (is_linux) {
        const pid = std.os.linux.getpid();
        print("pid={}\n", .{pid});

        const actionSighup = std.os.Sigaction{
            .sigaction = handleSighupLinux,
            .mask = std.os.empty_sigset,
            .flags = 0,
        };
        std.os.sigaction(std.os.SIGHUP, &actionSighup, null);

        const actionSigint = std.os.Sigaction{
            .sigaction = handleSigintLinux,
            .mask = std.os.empty_sigset,
            .flags = 0,
        };
        std.os.sigaction(std.os.SIGINT, &actionSigint, null);

        // print("sleeping 60 seconds...\n", .{});
        // std.os.nanosleep(60, 0);
    }

    var buffer2: [128]u8 = undefined;
    var input = try readStdIn(buffer2[0..]);
    print("input={}\n", .{input});

    input = try readStdIn(buffer2[0..]);
    print("input={}\n", .{input});

    print("done!\n", .{});
}

fn readStdIn(buffer: []u8) !?[]u8 {
    const stdin = std.io.getStdIn().inStream();
    print("input?> ", .{});
    const slice = try stdin.readUntilDelimiterOrEof(buffer, '\n'); // ignore errors
    return slice;
}

fn handleSighupLinux(sig: i32, info: *const std.os.siginfo_t, ctx_ptr: ?*const c_void) callconv(.C) void {
    print("\nhandleSighupLinux!\n", .{});
}

fn handleSigintLinux(sig: i32, info: *const std.os.siginfo_t, ctx_ptr: ?*const c_void) callconv(.C) void {
    print("\nhandleSigintLinux!\n", .{});
    std.os.exit(0);
}

// imports
const std = @import("std");
const print = std.debug.print;
