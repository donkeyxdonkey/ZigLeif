# ZigLeif
  zig utility
  working on
  0.15.0-dev.386+2e35fdd03

# Argument Parser
```zig
  const std = @import("std");
  const print = std.debug.print;
  const argsparser = @import("argsparser.zig");

  const Args = struct {
    something: i8 = 0,
  };

  pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var parsedArgs: Args = Args{};
    try argsparser.parse_args(@TypeOf(parsedArgs), allocator, &parsedArgs);

    print("f: {d}", .{parsedArgs.something});
  }
  ```

```shell
  zig build run -- --something 69
  ```
