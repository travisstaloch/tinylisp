const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // WASM executable
    const wasm_exe = b.addExecutable(.{
        .name = "tinylisp",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/wasm.zig"),
            .target = b.resolveTargetQuery(.{
                .cpu_arch = .wasm32,
                .os_tag = .freestanding,
            }),
            .optimize = optimize,
        }),
    });
    wasm_exe.entry = .disabled;
    wasm_exe.rdynamic = true;
    b.installArtifact(wasm_exe);

    // Local executable
    const exe = b.addExecutable(.{
        .name = "tinylisp",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(exe);
    const exe_run = b.addRunArtifact(exe);
    exe_run.step.dependOn(&exe.step);
    const run_step = b.step("run", "Run the local executable");
    run_step.dependOn(&exe_run.step);

    // expose module for dependees
    const mod = b.addModule("tinylisp", .{
        .root_source_file = b.path("src/tinylisp.zig"),
        .target = target,
        .optimize = optimize,
    });

    const tests = b.addTest(.{ .root_module = mod });
    const test_step = b.step("test", "Run tests");
    const run_tests = b.addRunArtifact(tests);
    test_step.dependOn(&run_tests.step);
}
