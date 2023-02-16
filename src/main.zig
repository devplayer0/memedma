const std = @import("std");
const rdma_cm = @cImport({
    @cInclude("rdma/rdma_cma.h");
});

const Test = struct {
    my_val: u32,
};

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    var cm_id: ?*rdma_cm.rdma_cm_id = null;
    var ctx = Test{
        .my_val = 123,
    };
    if (rdma_cm.rdma_create_id(null, &cm_id, &ctx, rdma_cm.RDMA_PS_TCP) != 0) {
        return error.RDMACMCreateIdFailed;
    }
    defer _ = rdma_cm.rdma_destroy_id(cm_id);

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
