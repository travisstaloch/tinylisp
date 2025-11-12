const std = @import("std");
const Io = std.Io;

pub const Imports = struct {
    extern fn jsTerminalWriteBuffer(ptr: [*]const u8, len: usize) void;
    extern fn jsTerminalFlushBuffer() void;
    extern fn jsConsoleLogWrite(ptr: [*]const u8, len: usize) void;
    extern fn jsConsoleLogFlush() void;
};

pub const Terminal = struct {
    pub fn writer() Io.Writer {
        return .{
            .buffer = &.{},
            .end = 0,
            .vtable = &.{ .drain = writeFn },
        };
    }

    fn writeFn(_: *Io.Writer, bytes: []const []const u8, _: usize) Io.Writer.Error!usize {
        Imports.jsTerminalWriteBuffer(bytes[0].ptr, bytes[0].len);
        return bytes[0].len;
    }
};

pub const Console = struct {
    pub const Logger = struct {
        pub const Error = error{};
        pub const Writer = std.io.GenericWriter(void, Error, write);

        fn write(_: void, bytes: []const u8) Error!usize {
            Imports.jsConsoleLogWrite(bytes.ptr, bytes.len);
            return bytes.len;
        }
    };

    pub fn writer() Console.Logger.Writer {
        return logger;
    }

    const logger = Logger.Writer{ .context = {} };
    pub fn log(comptime format: []const u8, args: anytype) void {
        logger.print(format, args) catch return;
        Imports.jsConsoleLogFlush();
    }
};
