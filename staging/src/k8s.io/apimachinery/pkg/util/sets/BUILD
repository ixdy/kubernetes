package(default_visibility = ["//visibility:public"])

load(
    "@io_bazel_rules_go//go:def.bzl",
    "go_library",
    "go_path",
    "go_test",
)

go_library(
    name = "go_default_library",
    srcs = [
        "byte.go",
        "doc.go",
        "empty.go",
        "int.go",
        "int64.go",
        "string.go",
    ],
    importpath = "k8s.io/apimachinery/pkg/util/sets",
)

go_path(
    name = "_set-gengo-gopath",
    mode = "copy",
    deps = [
        "//staging/src/k8s.io/apimachinery/pkg/util/sets/types:go_default_library",
    ],
)

genrule(
    name = "set-gen-new",
    srcs = [
        ":_set-gengo-gopath",
        "//hack/boilerplate:boilerplate.generatego.txt",
    ],
    outs = [
        "byte.go",
        "doc.go",
        "empty.go",
        "int.go",
        "int64.go",
        "string.go",
    ],
    cmd = """
    export GOPATH=$(location :_set-gengo-gopath)
    $(location //vendor/k8s.io/code-generator/cmd/set-gen) \
    --input-dirs k8s.io/apimachinery/pkg/util/sets/types \
    --output-base $$(dirname $$(dirname $(location :byte.go))) \
    --go-header-file $(location //hack/boilerplate:boilerplate.generatego.txt) \
    --output-package sets
    """,
    tools = ["//vendor/k8s.io/code-generator/cmd/set-gen"],
)

go_test(
    name = "go_default_test",
    srcs = ["set_test.go"],
    embed = [":go_default_library"],
)

filegroup(
    name = "package-srcs",
    srcs = glob(["**"]),
    tags = ["automanaged"],
    visibility = ["//visibility:private"],
)

filegroup(
    name = "all-srcs",
    srcs = [
        ":package-srcs",
        "//staging/src/k8s.io/apimachinery/pkg/util/sets/types:all-srcs",
    ],
    tags = ["automanaged"],
)
