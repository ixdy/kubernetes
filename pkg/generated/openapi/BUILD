load("@io_bazel_rules_go//go:def.bzl", "go_library")

package(default_visibility = ["//visibility:public"])

load("//pkg/generated/openapi:def.bzl", "gen_openapi", "openapi_deps")

gen_openapi(
    outs = ["zz_generated.openapi.go"],
)

go_library(
    name = "go_default_library",
    srcs = [
        "doc.go",
        "zz_generated.openapi.go",
    ],
    importpath = "k8s.io/kubernetes/pkg/generated/openapi",
    # keep
    deps = openapi_deps(),
)

filegroup(
    name = "package-srcs",
    srcs = glob(["**"]),
    tags = ["automanaged"],
    visibility = ["//visibility:private"],
)

filegroup(
    name = "all-srcs",
    srcs = [":package-srcs"],
    tags = ["automanaged"],
)
