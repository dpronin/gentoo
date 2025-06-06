# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_TEST="do"

inherit optfeature perl-module virtualx xdg-utils

DESCRIPTION="Scan documents, perform OCR, produce PDFs and DjVus"
HOMEPAGE="http://gscan2pdf.sourceforge.net/"
SRC_URI="https://downloads.sourceforge.net/${PN}/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 ~arm64 x86"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-perl/Config-General
	dev-perl/Data-UUID
	dev-perl/Date-Calc
	dev-perl/Filesys-Df
	dev-perl/glib-perl
	dev-perl/GooCanvas2
	dev-perl/Gtk3
	>=dev-perl/Gtk3-ImageView-10.0.0
	dev-perl/Gtk3-SimpleList
	dev-perl/HTML-Parser
	dev-perl/Image-Sane
	dev-perl/List-MoreUtils
	dev-perl/Locale-Codes
	dev-perl/Locale-gettext
	dev-perl/Log-Log4perl
	>=dev-perl/PDF-Builder-3.23.0
	dev-perl/Proc-ProcessTable
	dev-perl/Readonly
	dev-perl/Set-IntSpan
	dev-perl/Try-Tiny
	virtual/perl-Archive-Tar
	virtual/perl-Carp
	virtual/perl-Data-Dumper
	virtual/perl-File-Temp
	virtual/perl-Getopt-Long
	virtual/perl-threads
	media-gfx/imagemagick[png,tiff,perl]
	media-gfx/sane-backends
	media-libs/tiff"

BDEPEND="
	test? (
		${RDEPEND}
		dev-perl/IPC-System-Simple
		dev-perl/Sub-Override
		media-libs/fontconfig

		app-text/djvu[jpeg,tiff]
		app-text/poppler[utils]
		app-text/tesseract[-opencl(-),osd(+),png,tiff]
		app-text/unpaper
		media-gfx/imagemagick[djvu,jpeg,png,tiff,perl,postscript,truetype]
		media-gfx/sane-backends[sane_backends_test]
		media-gfx/sane-frontends
	)"

PATCHES=(
	"${FILESDIR}/${P}-min_max.patch"
	"${FILESDIR}/${P}-tiff2ps.patch"
	"${FILESDIR}/${P}-t131.patch"
	"${FILESDIR}/${P}-t1161.patch"
)

PERL_RM_FILES=( t/{90_MANIFEST,91_critic,99_pod,135_save_tiff_as_ps_with_space,169_import_scan,0601_Dialog_Scan,1171_prepend_pdf,1172_append_pdf,1173_prepend_pdf_with_space,1174_prepend_pdf_with_inverted_comma,1175_append_with_timestamp,1621_import_pdf,1622_import_multipage_PDF,1623_import_multipage_PDF2,1624_import_multipage_PDF3,1625_import_pdf_bw,1626_import_PDF_with_error,1627_import_encrypted_pdf,1628_import_pdf_metadata}.t )

mydoc="History"

src_test() {
	einfo "Using:"
	einfo "  $(best_version app-text/djvu)"
	einfo "  $(best_version app-text/poppler)"
	einfo "  $(best_version app-text/tesseract)"
	einfo "  $(best_version dev-perl/Gtk3-ImageView)"
	einfo "  $(best_version dev-perl/Image-Sane)"
	einfo "  $(best_version dev-perl/PDF-Builder)"
	einfo "  $(best_version media-gfx/imagemagick)"
	einfo "  $(best_version media-gfx/sane-backends)"
	einfo "  $(best_version media-libs/tiff)"

	local confdir="${HOME}/.config/ImageMagick"
	mkdir -p "${confdir}" || die
	cat > "${confdir}/policy.xml" <<-EOT || die
		<policymap>
			<policy domain="coder" rights="read|write" pattern="PDF" />
			<policy domain="coder" rights="read" pattern="PS" />
		</policymap>
	EOT
	NO_AT_BRIDGE=1 virtx perl-module_src_test
}

pkg_postinst() {
	xdg_desktop_database_update

	optfeature "DjVu file support" "app-text/djvu[tiff] media-gfx/imagemagick[djvu]"
	optfeature "encrypting PDFs" app-text/pdftk
	optfeature "creating PostScript files from PDFs" app-text/poppler[utils]
	optfeature "adding to an existing PDF" app-text/poppler[utils]
	optfeature "Optical Character Recognition" app-text/tesseract[tiff]
	optfeature "scan post-processing" app-text/unpaper
	optfeature "automatic document feeder support" media-gfx/sane-frontends
	optfeature "sending PDFs as email attachments" x11-misc/xdg-utils
}

pkg_postrm() {
	xdg_desktop_database_update
}
