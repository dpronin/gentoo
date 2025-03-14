# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} )
PYTHON_REQ_USE="sqlite"

inherit autotools python-single-r1

DESCRIPTION="A PKCS#11 interface for TPM2 hardware"
HOMEPAGE="https://tpm2-software.github.io/"
SRC_URI="https://github.com/tpm2-software/tpm2-pkcs11/releases/download/${PV}/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"

IUSE="fapi test"
REQUIRED_USE="( ${PYTHON_REQUIRED_USE} )"

# Units tests only for now
RESTRICT="!test? ( test )"

RDEPEND="${PYTHON_DEPS}
	app-crypt/p11-kit
	app-crypt/tpm2-abrmd
	app-crypt/tpm2-tools[fapi?]
	!fapi? ( app-crypt/tpm2-tss:= )
	fapi? ( >=app-crypt/tpm2-tss-3.0.1:=[fapi] )
	dev-db/sqlite:3
	dev-libs/libyaml
	dev-libs/openssl:=
	$(python_gen_cond_dep '
		dev-python/bcrypt[${PYTHON_USEDEP}]
		dev-python/cryptography[${PYTHON_USEDEP}]
		dev-python/pyasn1[${PYTHON_USEDEP}]
		dev-python/pyasn1-modules[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/tpm2-pytss[${PYTHON_USEDEP}]
		')
"

DEPEND="test? ( dev-util/cmocka )
	${RDEPEND}"
BDEPEND="${PYTHON_DEPS}
	dev-build/autoconf-archive
	virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${PN}-1.9.1-Fix-prefix-install-variable.patch"
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		$(use_with fapi) \
		$(use_enable test unit)
}

src_install() {
	default
	python_domodule tools/tpm2_pkcs11
	python_newscript tools/tpm2_ptool.py tpm2_ptool
	find "${ED}" -name '*.la' -delete || die
}
