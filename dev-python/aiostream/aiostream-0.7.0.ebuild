# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( pypy3_11 python3_{11..14} )

inherit distutils-r1

DESCRIPTION="Generator-based operators for asynchronous iteration"
HOMEPAGE="
	https://pypi.org/project/aiostream/
	https://github.com/vxgmichel/aiostream/
"
SRC_URI="
	https://github.com/vxgmichel/aiostream/archive/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~riscv ~x86"

RDEPEND="
	dev-python/typing-extensions[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=( pytest-asyncio )
distutils_enable_tests pytest

src_prepare() {
	sed -i -e 's:--cov aiostream::' \
		pyproject.toml || die
	distutils-r1_src_prepare
}
