const std = @import("std");

const tinylisp = @import("tinylisp.zig");

pub fn main() anyerror!void {
    var writer = std.fs.File.stdout().writer(&.{});

    var lisp: tinylisp.Lisp = undefined;
    var stack: [1024]f64 = undefined;
    lisp.initPinned(&writer.interface, &stack);
    try lisp.repl(std.fs.File.stdin());
}
