const std = @import("std");
const common = @import("common");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var stdout_buffer: [256]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const MyRunner = common.Runner(solvePart1, solvePart2);

    // Try to load input.txt from the same directory
    const input = MyRunner.loadInput(allocator, "data/2025/1.bin") catch |err| {
        try stdout.print("Error loading input: {}\n\n\n", .{err});
        try stdout.flush();
        return err;
    };
    defer allocator.free(input);

    try MyRunner.run(allocator, stdout, input);
    try stdout.flush();
}

fn solvePart1(allocator: std.mem.Allocator, input: []const u8) !i64 {
    _ = allocator;
    _ = input;
    // Your solution here
    return 42;
}

fn solvePart2(allocator: std.mem.Allocator, input: []const u8) !i64 {
    _ = allocator;
    _ = input;
    // Your solution here
    return 84;
}

test "part 1" {
    const input =
        \\L68
        \\L30
        \\R48
        \\L5
        \\R60
        \\L55
        \\L1
        \\L99
        \\R14
        \\L82
    ;
    const result = try solvePart1(std.testing.allocator, input);
    try std.testing.expectEqual(@as(i64, 3), result);
}

test "part 2" {
    const input = "your test input";
    const result = try solvePart2(std.testing.allocator, input);
    try std.testing.expectEqual(@as(i64, 84), result);
}
