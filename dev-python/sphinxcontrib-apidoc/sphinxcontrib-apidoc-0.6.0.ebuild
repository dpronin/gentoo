# Copyright 2021-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..13} )

inherit distutils-r1 pypi

DESCRIPTION="Sphinx extension for running sphinx-apidoc on each build"
HOMEPAGE="
	https://pypi.org/project/sphinxcontrib-apidoc/
	https://github.com/sphinx-contrib/apidoc/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~riscv ~x86"

BDEPEND="
	dev-python/pbr[${PYTHON_USEDEP}]
"
RDEPEND="
	${BDEPEND}
	>=dev-python/sphinx-5.0.0[${PYTHON_USEDEP}]
"

distutils_enable_tests pytest

python_compile() {
	distutils-r1_python_compile
	find "${BUILD_DIR}" -name '*.pth' -delete || die
}

python_test() {
	distutils_write_namespace sphinxcontrib
	cd "${T}" || die
	epytest "${S}"/tests
}
