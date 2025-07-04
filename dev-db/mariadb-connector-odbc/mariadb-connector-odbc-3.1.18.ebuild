# Copyright 2018-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib flag-o-matic

DESCRIPTION="MariaDB Connector/ODBC"
HOMEPAGE="https://downloads.mariadb.org/connector-odbc/"
SRC_URI="mirror://mariadb/connector-odbc-${PV}/${P}-src.tar.gz"
S="${S}-src"

LICENSE="LGPL-2.1"
SLOT="0/3.1"
KEYWORDS="amd64 x86"
IUSE="ssl"

# USE=ssl merely enables the configuration options (seemingly for interactive
# sessions) and does not cause direct linking to any SSL libraries.  However,
# it doesn't make sense enable these configuration options unless the
# underlying mariadb-connector-c has ssl enabled, thus if we have USE=ssl,
# require mariadb-connector-c to have it too.
DEPEND="dev-db/mariadb-connector-c:=[ssl(+)?]
	dev-db/unixODBC"
RDEPEND="${DEPEND}"

src_prepare() {
	cmake_src_prepare

	sed -e "s,/lib/,/$(get_libdir)/,g" "${FILESDIR}/odbcinst2.ini" > odbcinst.ini || die
}

multilib_src_configure() {
	append-cppflags $(mariadb_config --cflags || die)
	local mycmakeargs=(
		-DWITH_SSL=$(usex ssl OPENSSL OFF)
		-DMARIADB_LINK_DYNAMIC=YES
		-DUSE_SYSTEM_INSTALLED_LIB=YES
		-DINSTALL_DOCDIR="/usr/share/doc/${PF}"
		-DINSTALL_LICENSEDIR="/usr/share/doc/${PF}"
		-DINSTALL_LIBDIR="$(get_libdir)/mariadb"
		-DINSTALL_PCDIR="$(get_libdir)/pkgconfig"
		#-DCMAKE_C_FLAGS="$(mariadb_config --cflags)"
	)
	cmake_src_configure
}

multilib_src_install_all() {
	insinto /usr/share/${PN}
	doins odbcinst.ini

	rm "${ED}/usr/share/doc/${PF}/COPYING" || die "Error removing COPYING file from installation"
}

pkg_postinst() {
	elog "Please remember to use emerge --config =${P} to install the ODBC ini files."
	elog "Alternatively run: /usr/bin/odbcinst -i -d -f /usr/share/${PN}/odbcinst.ini"
}

pkg_config() {
	[[ -n "${ROOT}" ]] && die "Sorry, non-standard ROOT setting is not supported."

	if /usr/bin/odbcinst -q -d -n maodbc &>/dev/null; then
		einfo "maodbc (MariaDB ODBC driver) has already been installed."
	else
		ebegin "Installing maodbc (MariaDB ODBC driver)"
		/usr/bin/odbcinst -i -d -f /usr/share/${PN}/odbcinst.ini
		eend ${?} || die
	fi
}
