# Note: Mutt has a large number of non-upstream patches available for
# it, some of which conflict with each other. These patches are also
# not kept up-to-date when new versions of mutt (occasionally) come
# out.
#
# To reduce Homebrew's maintenance burden, patches are not accepted
# for this formula. The NeoMutt project has a Homebrew tap for their
# patched version of Mutt: https://github.com/neomutt/homebrew-neomutt

class Mutt < Formula
  desc "Mongrel of mail user agents (part elm, pine, mush, mh, etc.)"
  homepage "http://www.mutt.org/"
  url "https://bitbucket.org/mutt/mutt/downloads/mutt-1.14.7.tar.gz"
  sha256 "e4f507b133253cb5eef27996b8668956cdf9caac622cf8adad13f0f9a4eda864"
  license "GPL-2.0-or-later"

  livecheck do
    url :stable
  end

  bottle do
    sha256 "cd52bab8d44903657b984e768df12a0ff2895302cdabd70fbd2de8c207a21986" => :catalina
    sha256 "58b6ea0b2ca007c5ef8b8c4e780f52fadb18d32137358a17111b980bd3236d39" => :mojave
    sha256 "accc53a75a7eed9a73531d31a6b8274795f31bc2dc44267f1a7f51e09b78d997" => :high_sierra
    sha256 "7e85b7f73fa17f213cc06068b756cd682c9de7c2a0a2bb151a83a67bbad4c2f5" => :x86_64_linux
  end

  head do
    url "https://gitlab.com/muttmua/mutt.git"

    resource "html" do
      url "https://muttmua.gitlab.io/mutt/manual-dev.html"
    end
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "gpgme"
  depends_on "openssl@1.1"
  depends_on "tokyo-cabinet"
  depends_on "krb5" unless OS.mac?

  uses_from_macos "bzip2"
  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  conflicts_with "tin",
    because: "both install mmdf.5 and mbox.5 man pages"

  def install
    user_in_mail_group = Etc.getgrnam("mail").mem.include?(ENV["USER"])
    effective_group = Etc.getgrgid(Process.egid).name

    args = %W[
      --disable-dependency-tracking
      --disable-warnings
      --prefix=#{prefix}
      --enable-debug
      --enable-hcache
      --enable-imap
      --enable-pop
      --enable-sidebar
      --enable-smtp
      --with-gss
      #{OS.mac? ? "--with-sasl" : "--with-sasl2"}
      --with-ssl=#{Formula["openssl@1.1"].opt_prefix}
      --with-tokyocabinet
      --enable-gpgme
    ]

    system "./prepare", *args
    system "make"

    # This permits the `mutt_dotlock` file to be installed under a group
    # that isn't `mail`.
    # https://github.com/Homebrew/homebrew/issues/45400
    inreplace "Makefile", /^DOTLOCK_GROUP =.*$/, "DOTLOCK_GROUP = #{effective_group}" unless user_in_mail_group

    system "make", "install"
    doc.install resource("html") if build.head?
  end

  def caveats
    <<~EOS
      mutt_dotlock(1) has been installed, but does not have the permissions lock
      spool files in /var/mail. To grant the necessary permissions, run

        sudo chgrp mail #{bin}/mutt_dotlock
        sudo chmod g+s #{bin}/mutt_dotlock

      Alternatively, you may configure `spoolfile` in your .muttrc to a file inside
      your home directory.
    EOS
  end

  test do
    system bin/"mutt", "-D"
    touch "foo"
    system bin/"mutt_dotlock", "foo"
    system bin/"mutt_dotlock", "-u", "foo"
  end
end
