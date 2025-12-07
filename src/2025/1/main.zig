const std = @import("std");
const testing = std.testing;
const math = std.math;

pub fn main() !void {
    std.debug.print("Hello, World!\n", .{});
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "solve" {
    const result = add(2, 3);
    try std.testing.expect(result == 5);
}
