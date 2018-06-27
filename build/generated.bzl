# Copyright 2018 The Kubernetes Authors.
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

# The go_prefix for this repository, needed to map relative package paths into
# a full-resolved go package.
go_prefix = "k8s.io/kubernetes"

# Pretty-prints the provided dict -> dict -> dict as a dict -> dict -> list,
# appending lines into output.
def _format_output_dict(id, tags, output):
    output.append("%s = {" % id)

    for tag in tags.keys():
        d = tags[tag]
        output.append("%s%s: {" % (4 * " ", repr(tag)))
        for k in d.keys():
            output.append("%s%s: [" % (8 * " ", repr(k)))
            for v in d[k].keys():
                output.append("%s%s," % (12 * " ", repr(v)))
            output.append("%s]," % (8 * " "))

        output.append("%s}," % (4 * " "))

    output.append("}\n")

def _find_generator_tag_pkgs_impl(repo_ctx):
    repo_root = repo_ctx.path(repo_ctx.attr._workspace).dirname

    result = repo_ctx.execute(
        ["grep", "--color=never", "-Hrox", "--include=*.go", "\\s*//\s*+k8s:\\S*=\\S*\\s*", repo_root],
        quiet = True,
    )
    if result.return_code:
        fail("failed searching for generator build tags: %s" % result.stderr)

    # Maps tag names -> go packages -> values found for that tag in that package
    tags_pkgs_values = {}

    # Maps tag names -> values found for that tag -> go packages with those tag/value mappings
    tags_values_pkgs = {}

    for line in result.stdout.splitlines():
        # Each line looks something like
        # /a/full/path/to/file.go:+k8s:foo=bar

        # First split out the filename from the matched tag blog
        fname, _, match = line.partition(":")

        # Remove the repo_root from the path, yielding just a relative path,
        # and remove the basename to yield the package name.
        pkg = fname[len("%s" % repo_root) + 1:].rpartition(sep = "/")[0]

        # Skip things like _examples packages
        if pkg.startswith("_") or "/_" in pkg:
            continue

        # Strip off the leading "+k8s:", then split into tag name and value
        tag, _, values = match.partition(":")[2].partition("=")

        # The value may have multiple values, e.g. +k8s:foo=bar,baz, so handle each
        # value separately
        for value in values.split(","):
            # Since Skylark doesn't have sets, we take the Go approach and fake a set using a dictionary
            tags_pkgs_values.setdefault(tag, default = {}).setdefault(pkg, default = {})[value] = True
            tags_values_pkgs.setdefault(tag, default = {}).setdefault(value, default = {})[pkg] = True

    output = []
    _format_output_dict("tags_pkgs_values", tags_pkgs_values, output)
    _format_output_dict("tags_values_pkgs", tags_values_pkgs, output)

    repo_ctx.file(
        "tags.bzl",
        content = "\n".join(output),
        executable = False,
    )

    # Bazel needs a BUILD file even though nothing is in it
    repo_ctx.file(
        "BUILD.bazel",
        content = "",
        executable = False,
    )

    # Ensure that this rule always runs by touching the WORKSPACE file
    repo_ctx.execute(["touch", repo_ctx.path(repo_ctx.attr._workspace)])

_find_generator_tag_pkgs = repository_rule(
    attrs = {
        "_workspace": attr.label(
            allow_single_file = True,
            default = "@//:WORKSPACE",
        ),
    },
    local = True,
    implementation = _find_generator_tag_pkgs_impl,
)

# Uses grep to find all k8s generator build tags defined in the repo.
# This produces a tags.bzl file with two dictionaries:
# - tags_pkgs_values:
#     maps generator build tags -> packages using that tag -> values of that tag found in the package
# - tags_values_pkgs:
#     maps generator build tags -> values of that tag -> Go packages with that tag/value mapping
#
# For example, to find all packages requesting OpenAPI generation (using +k8s:openapi-gen=true), you can use
#
# load("@io_k8s_generated//:tags.bzl", "tags_values_pkgs")
# pkgs = tags_values_pkgs["openapi-gen"]["true"]
def find_generator_tag_pkgs(name = "io_k8s_generated", **kw):
    _find_generator_tag_pkgs(name = name, **kw)

# Returns the Bazel label for the Go library for the provided package.
#
# This is intended to be used with the @io_k8s_generated//:tags.bzl dictionaries; for example:
#
# load("@io_k8s_generated//:tags.bzl", "tags_values_pkgs")
# some_rule(
#     ...
#     deps = [bazel_go_library(pkg) for pkg in tags_values_pkgs["openapi-gen"]["true"]],
#     ...
# )
def bazel_go_library(pkg):
    return "//%s:go_default_library" % pkg

# Returns the full Go package name for the provided package, suitable to pass to
# tools depending on the Go build library.
# If any packages are in staging/src, they are remapped to their intended path in vendor/.
#
# This is intended to be used with the @io_k8s_generated//:tags.bzl dictionaries; for example:
#
# genrule(
#     ...
#     cmd = "do something --pkgs=%s" % ",".join([go_pkg(pkg) for pkg in tags_values_pkgs["openapi-gen"]["true"]]),
#     ...
# )
def go_pkg(pkg):
    return go_prefix + "/" + pkg.replace("staging/src/", "vendor/", maxsplit = 1)
