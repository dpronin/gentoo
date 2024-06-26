# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="Command line editor for id3v2 tags"
HOMEPAGE="https://id3v2.sourceforge.net/"
SRC_URI="https://downloads.sourceforge.net/id3v2/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 ~hppa ppc ppc64 ~riscv x86"

DEPEND="media-libs/id3lib"
RDEPEND="${DEPEND}"

src_prepare() {
	default
	emake clean
}

src_configure() {
	tc-export CC CXX
}

src_install() {
	dobin id3v2
	doman id3v2.1
	einstalldocs
}
