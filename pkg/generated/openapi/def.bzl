# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("@io_kubernetes_build//defs:go.bzl", "go_genrule")
load("//build:generated.bzl", "go_prefix", "tags_values_pkgs")
load("//build:openapi.bzl", "openapi_vendor_prefix")

def openapi_deps():
    deps = [
        "//vendor/github.com/go-openapi/spec:go_default_library",
        "//vendor/k8s.io/kube-openapi/pkg/common:go_default_library",
    ]
    for pkg in tags_values_pkgs["openapi-gen"]["true"]:
        if pkg.startswith(go_prefix):
            # len + 1 to include /
            deps.append("//%s:go_default_library" % pkg[len(go_prefix) + 1:])
        else:
            deps.append("//staging/src/%s:go_default_library" % pkg)
    return deps

def gen_openapi(outs):
    go_genrule(
        name = "zz_generated.openapi",
        srcs = ["//" + openapi_vendor_prefix + "hack/boilerplate:boilerplate.go.txt"],
        outs = outs,
        cmd = " ".join([
            "$(location //vendor/k8s.io/code-generator/cmd/openapi-gen)",
            "--v 1",
            "--logtostderr",
            "--go-header-file $(location //" + openapi_vendor_prefix + "hack/boilerplate:boilerplate.go.txt)",
            "--output-file-base zz_generated.openapi",
            "--output-package " + go_prefix + "pkg/generated/openapi",
            "--input-dirs " + ",".join(tags_values_pkgs["openapi-gen"]["true"]),
            "&& cp $$GOPATH/src/" + go_prefix + "pkg/generated/openapi/zz_generated.openapi.go $(location :zz_generated.openapi.go)",
        ]),
        go_deps = openapi_deps(),
        tools = ["//vendor/k8s.io/code-generator/cmd/openapi-gen"],
    )
