class KymaCli < Formula
  desc "Kyma command-line interface"
  homepage "https://kyma-project.io"
  url "https://github.com/kyma-project/cli.git",
      tag:      "1.15.0",
      revision: "31ee12fdc214124aabb70be036d27e76ee8b9ad9"
  license "Apache-2.0"
  head "https://github.com/kyma-project/cli.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "b7a55116242f040d070ed81cadb372361609e6cc41902c85c02b6289e5e10121" => :catalina
    sha256 "33fc6118e946a2d3ec280dd3e49b784bd79607b41a60e36bfdfb3f6aaefec491" => :mojave
    sha256 "bef618a94baf34cc932a183b8200db73264fa22ddae55792e328ad0e000f3ff8" => :high_sierra
    sha256 "75926e3b9a359fea82d9cab6544417c29a643d394c4978ad7117637ef61ef1d0" => :x86_64_linux
  end

  depends_on "go@1.14" => :build

  def install
    system "make", OS.mac? ? "build-darwin" : "build-linux"
    bin.install OS.mac? ? "bin/kyma-darwin" : "bin/kyma-linux" => "kyma"
  end

  test do
    touch testpath/"kubeconfig"
    assert_match "invalid configuration",
      shell_output("#{bin}/kyma install --kubeconfig ./kubeconfig 2>&1", 1)
  end
end
