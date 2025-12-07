const std = @import("std");

pub fn build(b: *std.Build) !void {
    const allocator = b.allocator;

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const common_mod = blk: {
        std.fs.cwd().access("src/common.zig", .{}) catch break :blk null;
        break :blk b.createModule(.{ .root_source_file = b.path("src/common.zig") });
    };

    var it = (try std.fs.cwd().openDir(
        "./src",
        .{ .iterate = true },
    )).iterate();

    const all_tests = b.step("test", "Run all tests");

    while (try it.next()) |year_entry| {
        if (year_entry.kind == .directory and year_entry.name[0] != '.') {
            const year_path = try std.fs.path.join(allocator, &.{"src", year_entry.name});
            var day_it = (try std.fs.cwd().openDir(
                year_path,
                .{ .iterate = true },
            )).iterate();

            while (try day_it.next()) |entry| {
                if (entry.kind == .directory and entry.name[0] != '.') {
                    const name = try std.fmt.allocPrint(allocator, "{s}_{s}", .{year_entry.name, entry.name});

                    // Assuming each subfolder contains a `main.zig` file to be built
                    const subfolder_path = try std.fs.path.join(allocator, &.{ year_path, entry.name });

                    // Construct the path to the `main.zig` file in the subfolder
                    const source_file = try std.fs.path.join(allocator, &.{ subfolder_path, "main.zig" });

                    // If main.zig doesn't exist, skip
                    _ = std.fs.cwd().openFile(source_file, .{}) catch continue;

                    const exe = b.addExecutable(.{
                        .name = name,
                        .root_module = b.createModule(.{
                            .root_source_file = b.path(source_file),
                            .target = target,
                            .optimize = optimize,
                        }),
                    });

                    if(common_mod) |mod|{
                        exe.root_module.addImport("common", mod);
                    }

                    b.installArtifact(exe);

                    const run_cmd = b.addRunArtifact(exe);
                    run_cmd.step.dependOn(b.getInstallStep());

                    if (b.args) |args| {
                        run_cmd.addArgs(args);
                    }

                    const run_name = try std.fmt.allocPrint(allocator, "run_{s}", .{name});
                    const run_description = try std.fmt.allocPrint(allocator, "Run the app for day {s} of year {s}", .{entry.name, year_entry.name});
                    const run_step = b.step(run_name, run_description);
                    run_step.dependOn(&run_cmd.step);

                    const exe_unit_tests = b.addTest(.{
                        .root_module = b.createModule(.{
                            .root_source_file = b.path(source_file),
                            .target = target,
                            .optimize = optimize,
                        }),
                    });

                    if( common_mod) |mod| {
                        exe_unit_tests.root_module.addImport("common", mod);
                    }

                    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

                    const test_name = try std.fmt.allocPrint(allocator, "test_{s}", .{name});
                    const test_description = try std.fmt.allocPrint(allocator, "Run unit tests for day {s} of year {s}", .{entry.name, year_entry.name});
                    const test_step = b.step(test_name, test_description);
                    test_step.dependOn(&run_exe_unit_tests.step);

                    all_tests.dependOn(test_step);
                }
            }
        }
    }
}
