const std = @import("std");

pub fn Runner(comptime solve_part1: anytype, comptime solve_part2: anytype) type {
    return struct {
        pub fn run(allocator: std.mem.Allocator, stdout: *std.Io.Writer, input: []const u8) !void {
            // Part 1
            var timer1 = try std.time.Timer.start();
            const result1 = try solve_part1(allocator, input);
            const elapsed1 = timer1.read();

            try stdout.print("Part 1: {any} ({d:.3}ms)\n", .{
                result1,
                @as(f64, @floatFromInt(elapsed1)) / std.time.ns_per_ms,
            });

            // Part 2
            var timer2 = try std.time.Timer.start();
            const result2 = try solve_part2(allocator, input);
            const elapsed2 = timer2.read();

            try stdout.print("Part 2: {any} ({d:.3}ms)\n", .{
                result2,
                @as(f64, @floatFromInt(elapsed2)) / std.time.ns_per_ms,
            });

            try stdout.print("Total: {d:.3}ms\n", .{
                @as(f64, @floatFromInt(elapsed1 + elapsed2)) / std.time.ns_per_ms,
            });
        }

        pub fn loadInput(allocator: std.mem.Allocator, path: []const u8) ![]const u8 {
            const file = try std.fs.cwd().openFile(path, .{});
            defer file.close();
            return try file.readToEndAlloc(allocator, 1024 * 1024 * 10); // 10MB max
        }
    };
}
