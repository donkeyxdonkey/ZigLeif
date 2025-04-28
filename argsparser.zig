const std = @import("std");

pub fn parse_args(comptime T: type, allocator: std.mem.Allocator, parsed: *T) !void {
    errdefer {
        std.log.err("Failed to parse args", .{});
        std.process.exit(1);
    }

    const args = std.process.argsAlloc(allocator) catch {
        std.log.err("Failed to allocate args\n", .{});
        return;
    };
    defer std.process.argsFree(allocator, args);

    var skip: bool = false;

    inline for (std.meta.fields(T)) |field| {
        for (args, 0..) |arg, i| {
            if (skip) {
                defer skip = false;
                continue;
            }

            if (arg.len > 2 and std.mem.eql(u8, arg[0..2], "--")) {
                const option = arg[2..];
                if (!std.mem.eql(u8, option, field.name))
                    continue;

                switch (@TypeOf(@field(parsed.*, field.name))) {
                    bool => {
                        @field(parsed.*, field.name) = true;
                    },
                    []u8 => {
                        if (i + 1 != args.len and args[i].len > 2 and !std.mem.eql(u8, args[i + 1][0..2], "--")) {
                            @field(parsed.*, field.name) = args[i + 1];
                        } else {
                            std.log.warn("Invalid argument provided for: {s}", .{field.name});
                            std.process.exit(1);
                        }
                        skip = true;
                    },
                    i8, i16, i32, i64, i128 => {
                        if (i + 1 != args.len) {
                            const parsed_int = std.fmt.parseInt(@TypeOf(@field(parsed.*, field.name)), args[i + 1], 10) catch -1;
                            @field(parsed.*, field.name) = parsed_int;
                            skip = true;
                        } else {
                            std.log.warn("Invalid argument provided for: {s}", .{field.name});
                            std.process.exit(1);
                        }
                    },
                    u8, u16, u32, u64, u128 => {
                        if (i + 1 != args.len) {
                            const parsed_uint = std.fmt.parseUnsigned(@TypeOf(@field(parsed.*, field.name)), args[i + 1], 10) catch 0;
                            @field(parsed.*, field.name) = parsed_uint;
                            skip = true;
                        } else {
                            std.log.warn("Invalid argument provided for: {s}", .{field.name});
                            std.process.exit(1);
                        }
                    },
                    f16, f32, f64, f128 => {
                        if (i + 1 != args.len) {
                            const parsed_float = std.fmt.parseFloat(@TypeOf(@field(parsed.*, field.name)), args[i + 1]) catch -1;
                            @field(parsed.*, field.name) = parsed_float;
                            skip = true;
                        } else {
                            std.log.warn("Invalid argument provided for: {s}", .{field.name});
                            std.process.exit(1);
                        }
                    },
                    else => {
                        // do nothing, we don't care!
                    },
                }
            }
        }
    }
}
