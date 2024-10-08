# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} pypy3 )

inherit distutils-r1

# upstream doesn't do tags much
EGIT_COMMIT=220b1d16442eb4b6fafed338ee3b61f698a01e63
DESCRIPTION="A configurable HTML Minifier with safety features"
HOMEPAGE="https://github.com/mankyd/htmlmin"
SRC_URI="
	https://github.com/mankyd/htmlmin/archive/${EGIT_COMMIT}.tar.gz
		-> ${P}.gh.tar.gz"
S="${WORKDIR}/${PN}-${EGIT_COMMIT}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~ppc ~ppc64 ~riscv x86"

distutils_enable_tests unittest

src_prepare() {
	distutils-r1_src_prepare

	sed -i -e '/prune/d' MANIFEST.in || die
	# unused import
	sed -i -e '/cgi/d' htmlmin/main.py || die
}
