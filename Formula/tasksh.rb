class Tasksh < Formula
  desc "Shell wrapper for Taskwarrior commands"
  homepage "https://tasktools.org/projects/tasksh.html"
  url "https://taskwarrior.org/download/tasksh-1.2.0.tar.gz"
  sha256 "6e42f949bfd7fbdde4870af0e7b923114cc96c4344f82d9d924e984629e21ffd"
  head "https://github.com/GothenburgBitFactory/taskshell.git", :branch => "1.3.0"

  bottle do
    cellar :any_skip_relocation
    sha256 "17f99be8d0aea4c43877fbfb121b7989047f04650ccffa85e948859e8ee51e0b" => :high_sierra
    sha256 "fd1b333c777401c53d5ddc8aaf52150a2a15fea4230a91d457d9d99ce2819ee7" => :sierra
    sha256 "d695adcf10582123053612d98ed4bf988b22c50919598bf167bc2e62db142352" => :el_capitan
    sha256 "eca60f6195117a4fce9b80aa4e6d5c1d72e56231b6893d2812694565d01b2da0" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "task" => :recommended

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "#{bin}/tasksh", "--version"
    (testpath/".taskrc").write "data.location=#{testpath}/.task\n"
    assert_match "Created task 1.", pipe_output("#{bin}/tasksh", "add Test Task", 0)
  end
end
