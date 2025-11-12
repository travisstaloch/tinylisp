const tinylisp = @import("tinylisp.zig");
const JS = @import("JS.zig");

const std = @import("std");
const DebugAllocator = std.heap.DebugAllocator;

export fn _wasm_alloc(len: usize) [*]const u8 {
    const buf = std.heap.wasm_allocator.alloc(u8, len) catch {
        @panic("failed to allocate memory");
    };
    return buf.ptr;
}

export fn _wasm_free(ptr: [*]u8, len: usize) void {
    std.heap.wasm_allocator.free(ptr[0..len]);
}

var lisp: tinylisp.Lisp = undefined;
var stack: [1024]f64 = undefined;
var writer = JS.Terminal.writer();

export fn tinylisp_init() bool {
    lisp.initPinned(&writer, &stack);
    return true;
}

export fn tinylisp_run(code_ptr: [*]u8, code_len: u32) void {
    const code = code_ptr[0..code_len :0];
    const eval_expr = lisp.run(code) orelse lisp.err;
    lisp.printReplOutput(eval_expr) catch unreachable;
}
