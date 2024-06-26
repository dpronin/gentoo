# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="An SMTP proxy server for adding DKIM headers"
HOMEPAGE="http://dkimproxy.sourceforge.net"
SRC_URI="https://downloads.sourceforge.net/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="dev-perl/Mail-DKIM
		>=dev-perl/Net-Server-2.7.0
		dev-perl/Error
		dev-perl/MIME-tools"
RDEPEND="${DEPEND}"

src_install() {
	default
	newinitd "${FILESDIR}"/dkimproxy.in.initd dkimproxy.in
	newinitd "${FILESDIR}"/dkimproxy.out.initd dkimproxy.out
}
