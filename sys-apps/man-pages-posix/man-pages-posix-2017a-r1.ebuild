# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_P="${PN}-${PV:0:4}-${PV:0-1}"
DESCRIPTION="POSIX man-pages (0p, 1p, 3p)"
HOMEPAGE="https://www.kernel.org/doc/man-pages/"
SRC_URI="https://www.kernel.org/pub/linux/docs/man-pages/${PN}/${MY_P}.tar.xz"

LICENSE="freedist" # to be clarified, see bug 871636
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~x64-solaris"
IUSE=""
RESTRICT="binchecks"

RDEPEND="virtual/man !<sys-apps/man-pages-3"

S="${WORKDIR}/${PN}-${PV:0:4}"

src_configure() { :; }

src_compile() { :; }

src_install() {
	emake install DESTDIR="${ED}"
	dodoc man-pages-*.Announce README
}
