// sudo apt install libeditline-dev

pub fn main() u8 {
    const usage = "usage: ls|cat|quit";
    // c.using_history();

    while (true) {
        const s = c.readline("prompt> ");

        if (s == null or c.strcmp(s, "quit") == 0) {
            _ = c.puts("done.");
            return 0;
        }

        if (c.strcmp(s, "help") == 0) {
            _ = c.puts(usage);
        } else if (c.strcmp(s, "ls") == 0 or c.strcmp(s, "cat") == 0) {
            _ = c.printf("command '%s' not implemented yet.\n", s);
            c.add_history(s);
        } else {
            _ = c.puts(usage);
        }

        std.c.free(s);
    }
}

// imports
const std = @import("std");

const c = @cImport({
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("stdio.h");
    @cInclude("string.h");
    @cInclude("editline.h");
});
