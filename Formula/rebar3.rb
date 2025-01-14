class Rebar3 < Formula
  desc "Erlang build tool"
  homepage "https://github.com/erlang/rebar3"
  url "https://github.com/erlang/rebar3/archive/3.14.0.tar.gz"
  sha256 "1e1a0d1d88d9b69311714eede8393a8a443cc53f9291755aa3c4da1f89a1132c"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "d596ed99909d5a71bd1cb06e4b012e054c43229048de0dd57f7d4e4758de4f37" => :catalina
    sha256 "58ee1653c5cd6f60d8e99fad112ae0f1e965a19ecfbdf073115e7a1a53b5301b" => :mojave
    sha256 "05deae81e4f67c18b9bff241660e53843f97d2f31eb84fb74cc14a2e9eff0496" => :high_sierra
    sha256 "25783e40d6284ba6fa94dfe0a3d2e8998e7173b7ef261ccf8876e60ecd89c051" => :x86_64_linux
  end

  depends_on "erlang"

  def install
    system "./bootstrap"
    bin.install "rebar3"

    bash_completion.install "priv/shell-completion/bash/rebar3"
    zsh_completion.install "priv/shell-completion/zsh/_rebar3"
    fish_completion.install "priv/shell-completion/fish/rebar3.fish"
  end

  test do
    system bin/"rebar3", "--version"
  end
end
