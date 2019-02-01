package(default_visibility = ["//visibility:public"])

load("//build:workspace.bzl", "CNI_VERSION", "CRI_TOOLS_VERSION")
load("@io_k8s_repo_infra//defs:build.bzl", "release_filegroup")
load("@io_k8s_repo_infra//defs:rpm.bzl", "GOARCH_TO_RPMARCH", "k8s_rpm")

release_filegroup(
    name = "rpms",
    srcs = [],
    conditioned_srcs = {
        "@io_bazel_rules_go//go/platform:" + goarch: [
            ":cri-tools-%s" % goarch,
            ":kubeadm-%s" % goarch,
            ":kubectl-%s" % goarch,
            ":kubelet-%s" % goarch,
            ":kubernetes-cni-%s" % goarch,
        ]
        for goarch, rpmarch in GOARCH_TO_RPMARCH.items()
    },
    tags = ["manual"],
    visibility = ["//visibility:public"],
)

k8s_rpm(
    name = "kubectl",
    changelog = "//:CHANGELOG.md",
    data = [
        "//cmd/kubectl",
    ],
    spec_file = "kubectl.spec",
    tags = ["manual"],
    version_file = "//build:os_package_version",
)

k8s_rpm(
    name = "kubelet",
    changelog = "//:CHANGELOG.md",
    data = [
        "kubelet.service",
        "//cmd/kubelet",
    ],
    spec_file = "kubelet.spec",
    tags = ["manual"],
    version_file = "//build:os_package_version",
)

k8s_rpm(
    name = "kubeadm",
    changelog = "//:CHANGELOG.md",
    data = [
        "10-kubeadm.conf",
        "50-kubeadm.conf",
        "kubeadm.conf",
        "kubelet.env",
        "//cmd/kubeadm",
    ],
    spec_file = "kubeadm.spec",
    tags = ["manual"],
    version_file = "//build:os_package_version",
)

k8s_rpm(
    name = "kubernetes-cni",
    changelog = "//:CHANGELOG.md",
    data = [
        "@kubernetes_cni_{GOARCH}//file",
    ],
    spec_file = "kubernetes-cni.spec",
    tags = ["manual"],
    version = CNI_VERSION,
)

k8s_rpm(
    name = "cri-tools",
    data = [
        "@cri_tools_{GOARCH}//file",
    ],
    spec_file = "cri-tools.spec",
    tags = ["manual"],
    version = CRI_TOOLS_VERSION,
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
