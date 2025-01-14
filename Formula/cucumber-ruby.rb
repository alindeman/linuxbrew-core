class CucumberRuby < Formula
  desc "Cucumber for Ruby"
  homepage "https://cucumber.io"
  url "https://github.com/cucumber/cucumber-ruby/archive/v5.1.0.tar.gz"
  sha256 "4d3a96064450ddcd9f5836c43863667c3f8595adffb560192aa9b9c4b5d464d8"
  license "MIT"

  bottle do
    cellar :any_skip_relocation
    sha256 "2818db64905d2e7c936bee32fa6e5098705d4b9986cd3f1abe5df72e67c50193" => :catalina
    sha256 "7229b37fdca6d806523bf60e3ac712e56fe4306917fcafa017ec951fa7d194e9" => :mojave
    sha256 "ee7ec4ee8bb671091422ab866e2d9696762d60a03681e1080138928a536b17e5" => :high_sierra
    sha256 "c01a30b233b036f6c0a486a74e72c18acc1948d62e14f123c0b1c4add84b11e6" => :x86_64_linux
  end

  depends_on "pkg-config" => :build

  uses_from_macos "libffi", since: :catalina
  uses_from_macos "ruby", since: :catalina

  def install
    ENV["GEM_HOME"] = libexec
    system "gem", "build", "cucumber.gemspec"
    system "gem", "install", "cucumber-#{version}.gem"
    bin.install libexec/"bin/cucumber"
    bin.env_script_all_files(libexec/"bin", GEM_HOME: ENV["GEM_HOME"])
  end

  test do
    assert_match "create   features", shell_output("#{bin}/cucumber --init")
    assert_predicate testpath/"features", :exist?
  end
end
