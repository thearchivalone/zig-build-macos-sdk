const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addLibrary(.{
        .name = "macos_sdk",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });
    lib.root_module.addCSourceFile(.{ .file = b.path("stub.c"), .flags = &.{} });
    lib.linkLibC();
    addPaths(lib);
    b.installArtifact(lib);
}

pub fn addPaths(step: *std.Build.Step.Compile) void {
    step.root_module.addSystemFrameworkPath(.{ .cwd_relative = sdkPath("/Frameworks") });
    step.root_module.addSystemIncludePath(.{ .cwd_relative = sdkPath("/include") });
    step.root_module.addLibraryPath(.{ .cwd_relative = sdkPath("/lib") });
}

pub fn addPathsModule(m: *std.Build.Module) void {
    m.addSystemFrameworkPath(.{ .cwd_relative = sdkPath("/Frameworks") });
    m.addSystemIncludePath(.{ .cwd_relative = sdkPath("/include") });
    m.addLibraryPath(.{ .cwd_relative = sdkPath("/lib") });
}

fn sdkPath(comptime suffix: []const u8) []const u8 {
    if (suffix[0] != '/') @compileError("suffix must be an absolute path");
    return comptime blk: {
        const root_dir = std.fs.path.dirname(@src().file) orelse ".";
        break :blk root_dir ++ suffix;
    };
}
