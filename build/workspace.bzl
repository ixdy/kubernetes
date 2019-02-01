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

load("//build:workspace_mirror.bzl", "mirror")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("@io_bazel_rules_docker//container:container.bzl", "container_pull")

CNI_VERSION = "0.6.0"

_CNI_TARBALL_ARCH_SHA256 = {
    "amd64": "f04339a21b8edf76d415e7f17b620e63b8f37a76b2f706671587ab6464411f2d",
    "arm": "ffb62021d2fc6e1266dc6ef7f2058125b6e6b44c016291a2b04a15ed9b4be70a",
    "arm64": "016bbc989877e35e3cd49fafe11415fb2717e52c74fde6b1650411154cb91b81",
    "ppc64le": "dd38dec69b167cfe40ecbba4b18cfe5b4296f2e49b90c00804b3988ef968e859",
    "s390x": "7708289eee7e52ad055407c421033d8e593f5cf1a0b43a872f09eb4e1508aafc",
}

def cni_tarballs():
    for arch, sha in _CNI_TARBALL_ARCH_SHA256.items():
        http_file(
            name = "kubernetes_cni_%s" % arch,
            downloaded_file_path = "kubernetes_cni.tgz",
            sha256 = sha,
            urls = mirror("https://storage.googleapis.com/kubernetes-release/network-plugins/cni-plugins-%s-v%s.tgz" % (arch, CNI_VERSION)),
        )

CRI_TOOLS_VERSION = "1.12.0"

_CRI_TARBALL_ARCH_SHA256 = {
    "amd64": "e7d913bcce40bf54e37ab1d4b75013c823d0551e6bc088b217bc1893207b4844",
    "arm": "ca6b4ac80278d32d9cc8b8b19de140fd1cc35640f088969f7068fea2df625490",
    "arm64": "8466f08b59bf36d2eebcb9428c3d4e6e224c3065d800ead09ad730ce374da6fe",
    "ppc64le": "ec6254f1f6ffa064ba41825aab5612b7b005c8171fbcdac2ca3927d4e393000f",
    "s390x": "814aa9cd496be416612c2653097a1c9eb5784e38aa4889034b44ebf888709057",
}

def cri_tarballs():
    for arch, sha in _CRI_TARBALL_ARCH_SHA256.items():
        http_file(
            name = "cri_tools_%s" % arch,
            downloaded_file_path = "cri_tools.tgz",
            sha256 = sha,
            urls = mirror("https://github.com/kubernetes-incubator/cri-tools/releases/download/v%s/crictl-v%s-linux-%s.tar.gz" % (CRI_TOOLS_VERSION, CRI_TOOLS_VERSION, arch)),
        )

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
