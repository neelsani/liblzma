const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addLibrary(.{
        .name = "liblzma",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(lib);
    const upstream = b.dependency("upstream", .{});

    lib.addIncludePath(upstream.path("src/common"));
    lib.addIncludePath(upstream.path("src/liblzma/api"));
    lib.addIncludePath(upstream.path("src/liblzma/check"));
    lib.addIncludePath(upstream.path("src/liblzma/common"));
    lib.addIncludePath(upstream.path("src/liblzma/rangecoder"));
    lib.addIncludePath(upstream.path("src/liblzma/delta"));
    lib.addIncludePath(upstream.path("src/liblzma/lz"));
    lib.addIncludePath(upstream.path("src/liblzma/lzma"));
    lib.addIncludePath(upstream.path("src/liblzma/simple"));

    lib.root_module.addCMacro("HAVE_STDBOOL_H", "1");
    lib.root_module.addCMacro("HAVE_STDINT_H", "1");
    lib.root_module.addCMacro("HAVE_DECODER_LZMA1", "1");
    lib.root_module.addCMacro("HAVE_DECODER_LZMA2", "1");
    lib.root_module.addCMacro("HAVE_CHECK_CRC32", "1");
    lib.installHeadersDirectory(
        upstream.path("src/liblzma/api"),

        "",
        .{ .include_extensions = &.{".h"} },
    );
    const arch = target.result.cpu.arch;

    // TODO: other archs
    // <https://github.com/winlibs/liblzma/blob/e41fdf12b0c0be6d4910f41c137deacc24279c9c/src/liblzma/common/filter_common.c>
    if (arch.isX86()) {
        lib.root_module.addCMacro("HAVE_DECODER_X86", "1");
        lib.addCSourceFile(.{
            .file = upstream.path("src/liblzma/simple/x86.c"),
        });
    } else if (arch.isArm()) {
        lib.root_module.addCMacro("HAVE_DECODER_ARM", "1");
        lib.addCSourceFile(.{
            .file = upstream.path("src/liblzma/simple/arm.c"),
        });
    } else if (arch.isAARCH64()) {
        lib.root_module.addCMacro("HAVE_DECODER_ARM64", "1");
        lib.addCSourceFile(.{
            .file = upstream.path("src/liblzma/simple/arm64.c"),
        });
    } else if (arch.isRISCV()) {
        lib.root_module.addCMacro("HAVE_DECODER_RISCV", "1");
        lib.addCSourceFile(.{
            .file = upstream.path("src/liblzma/simple/riscv.c"),
        });
    }

    lib.addCSourceFiles(.{
        .root = upstream.path("."),
        .files = &.{
            "src/liblzma/check/check.c",
            "src/liblzma/check/crc32_fast.c",
            "src/liblzma/check/crc32_table.c",
            "src/liblzma/common/block_decoder.c",
            "src/liblzma/common/block_header_decoder.c",
            "src/liblzma/common/block_util.c",
            "src/liblzma/common/common.c",
            "src/liblzma/common/filter_common.c",
            "src/liblzma/common/filter_decoder.c",
            "src/liblzma/common/filter_flags_decoder.c",
            "src/liblzma/common/index_hash.c",
            "src/liblzma/common/stream_buffer_decoder.c",
            "src/liblzma/common/stream_decoder.c",
            "src/liblzma/common/stream_flags_common.c",
            "src/liblzma/common/stream_flags_decoder.c",
            "src/liblzma/common/vli_decoder.c",
            "src/liblzma/common/vli_size.c",
            "src/liblzma/lz/lz_decoder.c",
            "src/liblzma/lzma/lzma2_decoder.c",
            "src/liblzma/lzma/lzma_decoder.c",
            "src/liblzma/simple/simple_coder.c",
            "src/liblzma/simple/simple_decoder.c",
        },
    });

    lib.linkLibC();
}
