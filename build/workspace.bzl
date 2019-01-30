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

load("@io_bazel_rules_docker//container:container.bzl", "container_pull")

CRI_TOOLS_VERSION = "1.12.0"

CNI_VERSION = "0.6.0"

def debian_base_image_dependencies():
    for arch in [
        "amd64",
        "arm",
        "arm64",
        "ppc64le",
        "s390x",
    ]:
        container_pull(
            name = "debian-base-" + arch,
            architecture = arch,
            digest = "sha256:b70f7099dbcb5b306c6d97285701e0191d851061bce24d5c28f32cf303318583",
            registry = "k8s.gcr.io",
            repository = "debian-base",
            tag = "0.4.0",  # ignored, but kept here for documentation
        )

        container_pull(
            name = "debian-iptables-" + arch,
            architecture = arch,
            digest = "sha256:cd81b1a8f40149b5061735927d2a2cf4b90fc27a52fc4cc66889b373368b6ef6",
            registry = "k8s.gcr.io",
            repository = "debian-iptables",
            tag = "v11.0",  # ignored, but kept here for documentation
        )

        container_pull(
            name = "debian-hyperkube-base-" + arch,
            architecture = arch,
            digest = "sha256:f3d34f92a41e9e57b4b5d5dc0d5cb4adb06a4a2e16474f66fab18b92ef21ba1d",
            registry = "k8s.gcr.io",
            repository = "debian-hyperkube-base",
            tag = "0.12.0",  # ignored, but kept here for documentation
        )
