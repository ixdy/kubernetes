load("//build:generated.bzl", "bazel_go_library", "go_pkg", "go_prefix")
load("@io_k8s_generated//:tags.bzl", "tags_values_pkgs")
load("@io_kubernetes_build//defs:go.bzl", "go_genrule")

def copy_cmd(pkgs, basename):
    cmd = []
    for p in pkgs:
        fname = "%s/%s.go" % (go_pkg(p), basename)
        cmd.append("&& cp $$GOPATH/src/%s $$ORIG_WD/$(location %s)" % (fname, fname))
    return cmd

def gen_deepcopy_all():
    pkg_set = {}
    for v in tags_values_pkgs["deepcopy-gen"].keys():
        if v == "false":
            continue
        for p in tags_values_pkgs["deepcopy-gen"][v]:
            pkg_set[p] = True
    pkgs = pkg_set.keys()

    basename = "zz_generated.deepcopy"

    # In order for vendored dependencies to be imported correctly,
    # the generator must run from the repo root inside the generated GOPATH.
    # All of bazel's $(location)s are relative to the original working directory, however,
    # so we must save it first.
    cmd = [
        "ORIG_WD=$$(pwd);",
        "cd $$GOPATH/src/" + go_prefix + ";",
        "$$ORIG_WD/$(location //vendor/k8s.io/code-generator/cmd/deepcopy-gen)",
        "--v 1",
        "--logtostderr",
        "--go-header-file $$ORIG_WD/$(location //hack/boilerplate:boilerplate.generatego.txt)",
        "--output-file-base " + basename,
        "--input-dirs " + ",".join([go_pkg(pkg) for pkg in pkgs]),
    ]
    cmd.extend(copy_cmd(pkgs, basename))

    go_genrule(
        name = "gen_deepcopy_all",
        srcs = ["//hack/boilerplate:boilerplate.generatego.txt"],
        outs = ["%s/%s.go" % (go_pkg(pkg), basename) for pkg in pkgs],
        cmd = " ".join(cmd),
        go_deps = [bazel_go_library(pkg) for pkg in pkgs],
        tools = ["//vendor/k8s.io/code-generator/cmd/deepcopy-gen"],
    )

def gen_defaulter_all():
    pkg_set = {}
    for v in tags_values_pkgs["defaulter-gen"].keys():
        for p in tags_values_pkgs["defaulter-gen"][v]:
            pkg_set[p] = True
    pkgs = pkg_set.keys()

    basename = "zz_generated.defaults"
    cmd = [
        "ORIG_WD=$$(pwd);",
        "cd $$GOPATH/src/" + go_prefix + ";",
        "$$ORIG_WD/$(location //vendor/k8s.io/code-generator/cmd/defaulter-gen)",
        "--v 1",
        "--logtostderr",
        "--go-header-file $$ORIG_WD/$(location //hack/boilerplate:boilerplate.generatego.txt)",
        "--output-file-base " + basename,
        "--input-dirs " + ",".join([go_pkg(pkg) for pkg in pkgs]),
        "--extra-peer-dirs " + ",".join([go_pkg(pkg) for pkg in pkgs]),
    ]
    cmd.extend(copy_cmd(pkgs, basename))

    go_genrule(
        name = "gen_defaulter_all",
        srcs = ["//hack/boilerplate:boilerplate.generatego.txt"],
        outs = ["%s/%s.go" % (go_pkg(pkg), basename) for pkg in pkgs],
        cmd = " ".join(cmd),
        go_deps = [bazel_go_library(pkg) for pkg in pkgs],
        tools = ["//vendor/k8s.io/code-generator/cmd/defaulter-gen"],
    )

def gen_conversion_all():
    extra_peer_pkgs = {
        "pkg/apis/core": True,
        "pkg/apis/core/v1": True,
        "staging/src/k8s.io/api/core/v1": True,
    }

    dep_pkgs = {}
    pkg_set = {}
    for v in tags_values_pkgs["conversion-gen"].keys():
        if v == "false":
            continue

        # TODO: we probably shouldn't assume that everything lives in staging ...
        if v.startswith(go_prefix):
            extra_pkg = v[len(go_prefix) + 1:].replace("vendor/k8s.io", "staging/src/k8s.io")
        else:
            extra_pkg = "staging/src/" + v
        dep_pkgs[extra_pkg] = True

        for p in tags_values_pkgs["conversion-gen"][v]:
            pkg_set[p] = True
    pkgs = pkg_set.keys()

    print(extra_peer_pkgs.keys())

    for p in extra_peer_pkgs.keys():
        pkg_set[p] = True
    for p in dep_pkgs.keys():
        pkg_set[p] = True
    all_pkgs = pkg_set.keys()

    basename = "zz_generated.conversion"
    cmd = [
        "ORIG_WD=$$(pwd);",
        "cd $$GOPATH/src/" + go_prefix + ";",
        "$$ORIG_WD/$(location //vendor/k8s.io/code-generator/cmd/conversion-gen)",
        "--v 1",
        "--logtostderr",
        "--go-header-file $$ORIG_WD/$(location //hack/boilerplate:boilerplate.generatego.txt)",
        "--output-file-base " + basename,
        "--input-dirs " + ",".join([go_pkg(pkg) for pkg in pkgs]),
        "--extra-peer-dirs " + ",".join([go_pkg(pkg) for pkg in extra_peer_pkgs]),
    ]
    cmd.extend(copy_cmd(pkgs, basename))

    go_genrule(
        name = "gen_conversion_all",
        srcs = ["//hack/boilerplate:boilerplate.generatego.txt"],
        outs = ["%s/%s.go" % (go_pkg(pkg), basename) for pkg in pkgs],
        cmd = " ".join(cmd),
        go_deps = [bazel_go_library(pkg) for pkg in all_pkgs],
        tools = ["//vendor/k8s.io/code-generator/cmd/conversion-gen"],
    )
