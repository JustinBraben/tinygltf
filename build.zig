const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const tinygltf = b.dependency("tinygltf", .{});

    const mod = b.addModule("tinygltf", .{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });

    const lib = b.addLibrary(.{
        .name = "tinygltf",
        .linkage = .static,
        .root_module = mod,
    });

    mod.addCSourceFile(.{
        .file = tinygltf.path("tiny_gltf.cc"),
        .flags = &.{
            "-std=c++11",
        },
    });
    mod.addIncludePath(tinygltf.path("."));

    // Install headers
    lib.installHeader(tinygltf.path("tiny_gltf.h"), "tiny_gltf.h");
    lib.installHeader(tinygltf.path("json.hpp"), "json.hpp");
    lib.installHeader(tinygltf.path("stb_image.h"), "stb_image.h");
    lib.installHeader(tinygltf.path("stb_image_write.h"), "stb_image_write.h");

    // Install the library
    b.installArtifact(lib);

    // const test_tinygltf_api = b.addExecutable(.{
    //     .name = "test_gltf_api",
    //     .root_module = b.createModule(.{
    //         .target = target,
    //         .optimize = optimize,
    //         .link_libc = true,
    //         .link_libcpp = true,
    //     }),
    // });

    // test_tinygltf_api.root_module.linkLibrary(lib);
    // test_tinygltf_api.root_module.addCSourceFile(.{
    //     .file = tinygltf.path("tests/tester.cc"),
    //     .flags = &.{
    //         "-std=c++11",
    //         "-fsanitize=address",
    //         "-Wall",
    //         "-Werror",
    //         "-Weverything",
    //         "-Wno-c++11-long-long",
    //     },
    // });
    // test_tinygltf_api.root_module.addIncludePath(tinygltf.path("."));

    // const run_test = b.addRunArtifact(test_tinygltf_api);

    // const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&run_test.step);

    const loader_example_step = b.step("loader_example", "Run loader_example");
    const loader_example_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });
    const loader_example = b.addExecutable(.{
        .name = "loader_example",
        .root_module = loader_example_mod,
    });

    loader_example_mod.addCSourceFile(.{
        .file = tinygltf.path("loader_example.cc"),
        .flags = &.{"-std=c++11"},
    });
    loader_example_mod.addIncludePath(tinygltf.path("."));
    loader_example_mod.linkLibrary(lib);

    b.installArtifact(loader_example);

    const loader_example_run = b.addRunArtifact(loader_example);
    if (b.args) |args| {
        loader_example_run.addArgs(args);
    }
    loader_example_step.dependOn(&loader_example_run.step);

    // const build_gl_examples = b.option(bool, "gl_examples", "Build GL examples(requires glfw, OpenGL, etc)") orelse false;
    // if (build_gl_examples) {
    //     _ = createGltfUtil(b, target, optimize, lib);
    // }

    // const build_validator_example = b.option(bool, "validator_example", "Build validator example") orelse false;
    // if (build_validator_example) {
    //     const validator_example = b.addExecutable(.{
    //         .name = "tinygltf-validator",
    //         .root_module = b.createModule(.{
    //             .target = target,
    //             .optimize = optimize,
    //             .link_libc = true,
    //             .link_libcpp = true,
    //         }),
    //     });

    //     validator_example.addCSourceFiles(.{
    //         .files = &.{
    //             "examples/validator/app/tinygltf-validate.cc",
    //             // // Unrecognized token
    //             // "examples/validator/src/json-schema.hpp",
    //             "examples/validator/src/json-schema-draft4.json.cpp",
    //             "examples/validator/src/json-uri.cpp",
    //             "examples/validator/src/json-validator.cpp",
    //         },
    //         .flags = &.{"-std=c++11"},
    //     });

    //     validator_example.addIncludePath(b.path("examples/validator/src"));
    //     validator_example.linkLibrary(lib);

    //     const build_validator_example_step = b.step("example", "Build the example app");
    //     build_validator_example_step.dependOn(&validator_example.step);

    //     b.installArtifact(validator_example);

    //     const run_validator_example = b.addRunArtifact(validator_example);
    //     const run_step = b.step("run-validator_example", "Run the validator_example");
    //     if (b.args) |args| {
    //         run_validator_example.addArgs(args);
    //     }
    //     run_step.dependOn(&run_validator_example.step);
    // }

    // const build_builder_example = b.option(bool, "builder_example", "Build glTF builder example") orelse false;
    // if (build_builder_example) {
    //     const builder_example = b.addExecutable(.{
    //         .name = "create_triangle_gltf",
    //         .root_module = b.createModule(.{
    //             .target = target,
    //             .optimize = optimize,
    //             .link_libc = true,
    //             .link_libcpp = true,
    //         }),
    //     });

    //     builder_example.addCSourceFiles(.{
    //         .files = &.{
    //             "examples/build-gltf/create_triangle_gltf.cpp",
    //         },
    //         .flags = &.{"-std=c++11"},
    //     });

    //     builder_example.addIncludePath(b.path("."));
    //     builder_example.linkLibrary(lib);

    //     const build_builder_example_step = b.step("example", "Build the example app");
    //     build_builder_example_step.dependOn(&builder_example.step);

    //     b.installArtifact(builder_example);

    //     const run_builder_example = b.addRunArtifact(builder_example);
    //     const run_step = b.step("run-builder_example", "Run the builder_example");
    //     if (b.args) |args| {
    //         run_builder_example.addArgs(args);
    //     }
    //     run_step.dependOn(&run_builder_example.step);
    // }

    // // option(TINYGLTF_HEADER_ONLY "On: header-only mode. Off: create tinygltf library(No TINYGLTF_IMPLEMENTATION required in your project)" OFF)
    // const build_header_example = b.option(bool, "header_example", "On: header-only mode. Off: create tinygltf library(No TINYGLTF_IMPLEMENTATION required in your project)") orelse false;
    // if (build_header_example) {
    //     const header_example = b.addExecutable(.{
    //         .name = "tinygltf",
    //         .root_module = b.createModule(.{
    //             .target = target,
    //             .optimize = optimize,
    //             .link_libc = true,
    //             .link_libcpp = true,
    //         }),
    //     });

    //     header_example.addCSourceFiles(.{
    //         .files = &.{
    //             "tiny_gltf.cc",
    //         },
    //         .flags = &.{"-std=c++11"},
    //     });

    //     header_example.addIncludePath(b.path("."));
    //     header_example.linkLibrary(lib);

    //     const build_header_example_step = b.step("example", "Build the header_example app");
    //     build_header_example_step.dependOn(&header_example.step);

    //     b.installArtifact(header_example);

    //     const run_header_example = b.addRunArtifact(header_example);
    //     const run_step = b.step("run-header_example", "Run the header_example");
    //     if (b.args) |args| {
    //         run_header_example.addArgs(args);
    //     }
    //     run_step.dependOn(&run_header_example.step);
    // }

    // option(TINYGLTF_INSTALL "Install tinygltf files during install step. Usually set to OFF if you include tinygltf through add_subdirectory()" ON)
    // option(TINYGLTF_INSTALL_VENDOR "Install vendored nlohmann/json and nothings/stb headers" ON)
}

fn createLibrary(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    tinygltf: *std.Build.Dependency,
) *std.Build.Step.Compile {
    const mod = b.addModule("tinygltf", .{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });

    const config = b.addConfigHeader(.{}, .{
        .LOADER_EXAMPLE = b.option(bool, "loader_example", "Build loader_example") orelse false,
        .GL_EXAMPLES = b.option(bool, "gl_examples", "Build GL examples(requires glfw, OpenGL, etc)") orelse false,
        // .VALIDATOR_EXAMPLE = b.option(bool, "validator_example", "Build validator example") orelse false,
        // .BUILDER_EXAMPLE = b.option(bool, "builder_example", "Build glTF builder example") orelse false,
        // .HEADER_ONLY = b.option(bool, "header_example", "On: header-only mode. Off: create tinygltf library(No TINYGLTF_IMPLEMENTATION required in your project)") orelse false,
    });
    mod.addConfigHeader(config);

    const lib = b.addLibrary(.{
        .name = "tinygltf",
        .linkage = .static,
        .root_module = mod,
    });

    mod.addCSourceFile(.{
        .file = tinygltf.path("tiny_gltf.cc"),
        .flags = &.{
            "-std=c++11",
        },
    });

    mod.addIncludePath(tinygltf.path("."));

    return lib;
}

fn createGltfUtil(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    lib: *std.Build.Step.Compile,
) *std.Build.Step.Compile {
    const gltf_util_example = b.addExecutable(.{
        .name = "gltfutil",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .link_libcpp = true,
        }),
    });

    gltf_util_example.addCSourceFiles(.{
        .files = &.{
            "examples/gltfutil/main.cc",
            "examples/gltfutil/texture_dumper.cc",
            "examples/common/lodepng.cpp"
        },
        .flags = &.{"-std=c++11"},
    });

    gltf_util_example.addIncludePath(b.path("."));
    gltf_util_example.addIncludePath(b.path("examples/common/"));
    gltf_util_example.linkLibrary(lib);

    const build_gl_examples_step = b.step("example", "Build the example app");
    build_gl_examples_step.dependOn(&gltf_util_example.step);

    b.installArtifact(gltf_util_example);

    const run_gltf_util = b.addRunArtifact(gltf_util_example);
    const run_step = b.step("run-gltf_util", "Run the gltf_util_example");
    if (b.args) |args| {
        run_gltf_util.addArgs(args);
    }
    run_step.dependOn(&run_gltf_util.step);

    return gltf_util_example;
}

/// Link tinygltf to a compile step when used as a dependency.
/// Usage in your project's build.zig:
/// ```zig
/// const tinygltf_dep = b.dependency("tinygltf", .{
///     .target = target,
///     .optimize = optimize,
/// });
/// const tinygltf = @import("tinygltf");
/// tinygltf.link(exe, tinygltf_dep);
/// ```
pub fn link(compile: *std.Build.Step.Compile, dep: *std.Build.Dependency) void {
    compile.addIncludePath(dep.path("."));
    compile.linkLibrary(dep.artifact("tinygltf"));
}