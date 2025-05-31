# liblzma Zig Build Integration

Zig build system integration for [liblzma](https://github.com/tukaani-project/xz) 

## Quick Start

1. Add to your project:
```bash
zig fetch --save git+https://github.com/neelsani/liblzma
```
2. Add to your build.zig

```zig
const liblzma_dep = b.dependency("liblzma", .{
    .target = target,
    .optimize = optimize,
});
const lib = liblzma_dep.artifact("liblzma");

//then link it to your exe

exe.linkLibrary(lib);
```