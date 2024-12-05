# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# TODO:
# - add USE flag for remote modules? Those modules can be downloaded
#	properly before building.
# - replace usex by usev where applicable

PYTHON_COMPAT=( python3_{10..12} )
WEBAPP_OPTIONAL=yes
WEBAPP_MANUAL_SLOT=yes

inherit check-reqs cmake cuda java-pkg-opt-2 multiprocessing python-single-r1 toolchain-funcs virtualx webapp

# Short package version
MY_PV="$(ver_cut 1-2)"

DESCRIPTION="The Visualization Toolkit"
HOMEPAGE="https://www.vtk.org/"
SRC_URI="
	https://www.vtk.org/files/release/${MY_PV}/VTK-${PV}.tar.gz
	doc? ( https://www.vtk.org/files/release/${MY_PV}/vtkDocHtml-${PV}.tar.gz )
	examples? (
		https://www.vtk.org/files/release/${MY_PV}/VTKLargeData-${PV}.tar.gz
		https://www.vtk.org/files/release/${MY_PV}/VTKLargeDataFiles-${PV}.tar.gz
	)
	test? (
		https://www.vtk.org/files/release/${MY_PV}/VTKData-${PV}.tar.gz
		https://www.vtk.org/files/release/${MY_PV}/VTKDataFiles-${PV}.tar.gz
		https://www.vtk.org/files/release/${MY_PV}/VTKLargeData-${PV}.tar.gz
		https://www.vtk.org/files/release/${MY_PV}/VTKLargeDataFiles-${PV}.tar.gz
	)
"
S="${WORKDIR}/VTK-${PV}"

LICENSE="BSD LGPL-2"
SLOT="0/${MY_PV}"
KEYWORDS="~amd64 ~arm ~arm64 ~x86 ~amd64-linux ~x86-linux"

# TODO: Like to simplify these. Mostly the flags related to Groups.
IUSE="all-modules boost +cgns cuda debug doc examples ffmpeg +freetype gdal gles2-only imaging
	java las +logging minimal mpi mysql +netcdf odbc opencascade openmp openvdb pdal postgres
	python qt6 +rendering sdl tbb test +threads tk video_cards_nvidia +views vtkm web"

RESTRICT="!test? ( test )"

REQUIRED_USE="
	all-modules? (
		boost cgns ffmpeg freetype gdal imaging las mysql netcdf odbc opencascade openvdb pdal
		postgres rendering views
	)
	cuda? ( video_cards_nvidia vtkm )
	java? ( rendering )
	minimal? ( !rendering )
	!minimal? ( cgns netcdf rendering )
	python? ( ${PYTHON_REQUIRED_USE} )
	qt6? ( rendering )
	sdl? ( rendering )
	tk? ( python rendering )
	web? ( python )
	rendering? ( freetype views )
"

# eigen, nlohmann_json, pegtl and utfcpp are referenced in the cmake files
# and need to be available when VTK consumers configure the dependencies.
RDEPEND="
	app-arch/lz4:=
	app-arch/xz-utils
	dev-db/sqlite:3
	dev-libs/double-conversion:=
	dev-libs/expat
	dev-libs/icu:=
	dev-libs/jsoncpp:=
	>=dev-libs/libfmt-8.1.1:=
	dev-libs/libxml2:2
	dev-libs/libzip:=
	dev-libs/pugixml
	media-libs/freetype
	media-libs/libjpeg-turbo
	media-libs/libogg
	media-libs/libpng:=
	media-libs/tiff:=
	sci-libs/hdf5:=[mpi=]
	sci-libs/proj:=
	sys-libs/zlib
	boost? ( dev-libs/boost:=[mpi?] )
	cgns? ( >=sci-libs/cgnslib-4.1.1:=[hdf5,mpi=] )
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	ffmpeg? ( media-video/ffmpeg:= )
	freetype? ( media-libs/fontconfig )
	gdal? ( sci-libs/gdal:= )
	java? ( >=virtual/jdk-11:= )
	las? ( sci-geosciences/liblas )
	!minimal? (
		>=media-libs/libharu-2.4.0:=
		media-libs/libtheora
	)
	mpi? ( virtual/mpi[cxx,romio] )
	mysql? ( dev-db/mariadb-connector-c )
	netcdf? ( sci-libs/netcdf:=[mpi=] )
	odbc? ( dev-db/unixODBC )
	openvdb? ( media-gfx/openvdb:= )
	opencascade? ( sci-libs/opencascade:= )
	pdal? ( sci-libs/pdal:= )
	postgres? ( dev-db/postgresql:= )
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep 'mpi? ( dev-python/mpi4py[${PYTHON_USEDEP}] )')
		$(python_gen_cond_dep 'rendering? ( dev-python/matplotlib[${PYTHON_USEDEP}] )')
	)
	qt6? (
		dev-qt/qtbase:6[gui,opengl,sql,widgets]
		dev-qt/qtdeclarative:6[opengl]
		dev-qt/qtshadertools:6
		x11-libs/libxkbcommon
	)
	sdl? ( media-libs/libsdl2 )
	rendering? (
		media-libs/glew:=
		media-libs/libglvnd[X]
		x11-libs/gl2ps
		x11-libs/libICE
		x11-libs/libXcursor
		x11-libs/libXext
	)
	tbb? ( dev-cpp/tbb:= )
	tk? ( dev-lang/tk:= )
	video_cards_nvidia? ( x11-drivers/nvidia-drivers[tools,static-libs] )
	views? (
		x11-libs/libICE
		x11-libs/libXext
	)
	web? ( ${WEBAPP_DEPEND} )
"

DEPEND="
	${RDEPEND}
	dev-cpp/cli11
	dev-cpp/eigen
	dev-cpp/nlohmann_json
	>=dev-libs/pegtl-3
	dev-libs/utfcpp
	test? (
		media-libs/glew
		x11-libs/libXcursor
		rendering? ( media-libs/freeglut )
	)
"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${PN}-9.2.5-pegtl-3.x.patch"
	"${FILESDIR}/${PN}-9.3.0-java.patch"
	"${FILESDIR}/${PN}-9.3.0-opencascade.patch"
	"${FILESDIR}/${PN}-9.3.0-ThrustPatches.patch"
	"${FILESDIR}/${PN}-9.3.0-core-octree_node.txx.patch"
	"${FILESDIR}/${PN}-9.3.0-ThirdParty-gcc15.patch"
	"${FILESDIR}/${PN}-9.3.0-update-for-cuda-12.6.patch"
	"${FILESDIR}/${PN}-9.3.1-fix-fmt-11.patch"
)

DOCS=( CONTRIBUTING.md README.md )

vtk_check_reqs() {
	local dsk=4096

	dsk=$(( $(usex doc 3072 0) + dsk ))
	dsk=$(( $(usex examples 3072 0) + dsk ))
	dsk=$(( $(usex cuda 8192 0) + dsk ))
	export CHECKREQS_DISK_BUILD=${dsk}M

	# In case users are not aware of the extra NINJAOPTS, check
	# for the more common MAKEOPTS, in case NINJAOPTS is empty
	local jobs=1
	if [[ -n "${NINJAOPTS}" ]]; then
		jobs=$(makeopts_jobs "${NINJAOPTS}" "$(get_nproc)")
	elif [[ -n "${MAKEOPTS}" ]]; then
		jobs=$(makeopts_jobs "${MAKEOPTS}" "$(get_nproc)")
	fi

	if use cuda; then
		local mem=$(( $(usex cuda 7168 0) ))
		mem=$(( mem * $(( jobs > 4 ? 4 : jobs )) ))
		export CHECKREQS_MEMORY=${mem}M
	fi

	"check-reqs_pkg_${EBUILD_PHASE}"
}

cuda_get_host_compiler() {
	if [[ -n "${NVCC_CCBIN}" ]]; then
		echo "${NVCC_CCBIN}"
		return
	fi

	if [[ -n "${CUDAHOSTCXX}" ]]; then
		echo "${CUDAHOSTCXX}"
		return
	fi

	einfo "Trying to find working CUDA host compiler"

	if ! tc-is-gcc && ! tc-is-clang; then
		die "$(tc-get-compiler-type) compiler is not supported"
	fi

	local compiler compiler_type compiler_version
	local package package_version
	local NVCC_CCBIN_default

	compiler_type="$(tc-get-compiler-type)"
	compiler_version="$("${compiler_type}-major-version")"

	# try the default compiler first
	NVCC_CCBIN="$(tc-getCXX)"
	NVCC_CCBIN_default="${NVCC_CCBIN}-${compiler_version}"

	compiler="${NVCC_CCBIN/%-${compiler_version}}"

	# store the package so we can re-use it later
	package="sys-devel/${compiler_type}"
	package_version="${package}"

	ebegin "testing ${NVCC_CCBIN_default} (default)"

	while ! nvcc -v -ccbin "${NVCC_CCBIN}" - -x cu <<<"int main(){}" &>> "${T}/cuda_get_host_compiler.log" ; do
		eend 1

		while true; do
			# prepare next version
			if ! package_version="<$(best_version "${package_version}")"; then
				die "could not find a supported version of ${compiler}"
			fi

			NVCC_CCBIN="${compiler}-$(ver_cut 1 "${package_version/#<${package}-/}")"

			[[ "${NVCC_CCBIN}" != "${NVCC_CCBIN_default}" ]] && break
		done
		ebegin "testing ${NVCC_CCBIN}"
	done
	eend $?

	# clean temp file
	rm -f a.out

	echo "${NVCC_CCBIN}"
	export NVCC_CCBIN
}

cuda_get_host_native_arch() {
	[[ -n ${CUDAARCHS} ]] && echo "${CUDAARCHS}"

	__nvcc_device_query || die "failed to query the native device"
}

vtk_add_sandbox() {
	local WRITE=()

	# mesa via virtx will make use of udmabuf if it exists
	[[ -c "/dev/udmabuf" ]] && WRITE+=( "/dev/udmabuf" )

	readarray -t dris <<<"$(
		for dri in /sys/class/drm/*/dev; do
			realpath "/dev/char/$(cat "${dri}")"
			eqawarn "dri ${dri} $(cat "${dri}") $(realpath "/dev/char/$(cat "${dri}")")"
		done
	)"

	[[ -n "${dris[*]}" ]] && WRITE+=( "${dris[@]}" )

	if [[ -d /sys/module/nvidia ]]; then
		# /dev/nvidia{0-9}
		readarray -t nvidia_devs <<<"$(
			find /dev -regextype posix-extended  -regex '/dev/nvidia(|-(nvswitch|vgpu))[0-9]*'
		)"
		[[ -n "${nvidia_devs[*]}" ]] && WRITE+=( "${nvidia_devs[@]}" )

		WRITE+=(
			"/dev/nvidiactl"
			"/dev/nvidia-modeset"

			"/dev/nvidia-vgpuctl"

			"/dev/nvidia-nvlink"
			"/dev/nvidia-nvswitchctl"

			"/dev/nvidia-uvm"
			"/dev/nvidia-uvm-tools"

			# "/dev/nvidia-caps/nvidia-cap%d"
			"/dev/nvidia-caps/"
			# "/dev/nvidia-caps-imex-channels/channel%d"
			"/dev/nvidia-caps-imex-channels/"
		)
	fi

	# for portage
	WRITE+=( "/proc/self/task/" )

	local dev
	for dev in "${WRITE[@]}"; do
		[[ ! -e "${dev}" ]] && return

		[[ -w "${dev}" ]] && return

		eqawarn "addwrite ${dev}"
		addwrite "${dev}"
		if [[ ! -d "${dev}" ]] && [[ ! -w "${dev}" ]]; then
			eerror "can not access ${dev} after addwrite"
		fi
	done
}

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && has openmp && tc-check-openmp

	vtk_check_reqs

	# When building binpkgs you probably want to include all targets
	if use cuda && [[ ${MERGE_TYPE} == "buildonly" ]] && [[ -n "${CUDA_GENERATION}" || -n "${CUDA_ARCH_BIN}" ]]; then
		local info_message="When building a binary package it's recommended to unset CUDA_GENERATION and CUDA_ARCH_BIN"
		einfo "$info_message so all available architectures are build."
	fi
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && has openmp && tc-check-openmp

	vtk_check_reqs

	if use cuda && [[ ! -e /dev/nvidia-uvm ]]; then
		# NOTE We try to load nvidia-uvm and nvidia-modeset here,
		# so __nvcc_device_query does not fail later.

		nvidia-modprobe -m -u -c 0 || true
	fi

	use java && java-pkg-opt-2_pkg_setup
	use python && python-single-r1_pkg_setup
	use web && webapp_pkg_setup
}

# Note: The following libraries are marked as internal by kitware
#	and can currently not unbundled:
#	diy2, exodusII, fides, h5part, kissfft, loguru, verdict, vpic,
#	vtkm, xdmf{2,3}, zfp
# TODO: exprtk, ioss
# Note: As of v9.2.2 we no longer drop bundled libraries, when using system
# libraries. This just saves a little space. CMake logic of VTK on ThirdParty
# libraries avoids automagic builds, so deletion is not needed to catch these.
src_prepare() {
	if use doc; then
		einfo "Removing .md5 files from documents."
		rm -f "${WORKDIR}"/html/*.md5 || die "Failed to remove superfluous hashes"
		sed -e "s|\${VTK_BINARY_DIR}/Utilities/Doxygen/doc|${WORKDIR}|" \
			-i Utilities/Doxygen/CMakeLists.txt || die
	fi

	if use opencascade && has_version ">=sci-libs/opencascade-7.8.0"; then
		eapply "${FILESDIR}/vtk-9.3.0-opencascade-7.8.0.patch"
	fi

	cmake_src_prepare

	if use test; then
		ebegin "Copying data files to ${BUILD_DIR}"
		mkdir -p "${BUILD_DIR}/ExternalData" || die
		pushd "${BUILD_DIR}/ExternalData" >/dev/null || die
		ln -sf "../../${S}/.ExternalData/README.rst" . || die
		ln -sf "../../${S}/.ExternalData/SHA512" . || die
		popd >/dev/null || die
		eend "$?"
	fi
}

# TODO: check these and consider to use them
#	VTK_BUILD_SCALED_SOA_ARRAYS
#	VTK_DISPATCH_{AOS,SOA,TYPED}_ARRAYS
src_configure() {
	local mycmakeargs=(
		-DCMAKE_DISABLE_FIND_PACKAGE_Git="yes"
		-DVTK_GIT_DESCRIBE="v${PV}"
		-DVTK_VERSION_FULL="${PV}"
		-DGIT_EXECUTABLE="${T}/notgit"

		-DCMAKE_POLICY_DEFAULT_CMP0167="OLD"
		-DCMAKE_POLICY_DEFAULT_CMP0174="OLD"
		-DCMAKE_POLICY_DEFAULT_CMP0177="OLD"

		-DCMAKE_INSTALL_LICENSEDIR="share/${PN}/licenses"
		-DVTK_IGNORE_CMAKE_CXX11_CHECKS=yes

		-DVTK_ANDROID_BUILD=OFF
		-DVTK_IOS_BUILD=OFF

		-DVTK_BUILD_ALL_MODULES="$(usex all-modules)"
		# we use the pre-built documentation and install these with USE=doc
		-DVTK_BUILD_DOCUMENTATION=OFF
		-DVTK_BUILD_EXAMPLES="$(usex examples)"

		# no package in the tree: https://github.com/LLNL/conduit
		-DVTK_ENABLE_CATALYST=OFF
		-DVTK_ENABLE_KITS=OFF
		-DVTK_ENABLE_LOGGING="$(usex logging)"
		# defaults to ON: USE flag for this?
		-DVTK_ENABLE_REMOTE_MODULES=OFF

		# disable fetching files during build
		-DVTK_FORBID_DOWNLOADS="yes"

		-DVTK_GROUP_ENABLE_Imaging="$(usex imaging "YES" "NO")"
		-DVTK_GROUP_ENABLE_Rendering="$(usex rendering "YES" "NO")"
		-DVTK_GROUP_ENABLE_StandAlone="$(usex minimal "NO" "YES")"
		-DVTK_GROUP_ENABLE_Views="$(usex views "YES" "NO")"
		-DVTK_GROUP_ENABLE_Web="$(usex web "YES" "NO")"

		-DVTK_INSTALL_SDK=ON

		-DVTK_MODULE_ENABLE_VTK_IOCGNSReader="$(usex cgns "YES" "NO")"
		-DVTK_MODULE_ENABLE_VTK_IOExportPDF="$(usex minimal "NO" "YES")"
		-DVTK_MODULE_ENABLE_VTK_IOLAS="$(usex las "YES" "NO")"
		-DVTK_MODULE_ENABLE_VTK_IONetCDF="$(usex netcdf "YES" "NO")"
		-DVTK_MODULE_ENABLE_VTK_IOOCCT="$(usex opencascade "YES" "NO")"
		-DVTK_MODULE_ENABLE_VTK_IOOggTheora="$(usex minimal "NO" "YES")"
		-DVTK_MODULE_ENABLE_VTK_IOOpenVDB="$(usex openvdb "YES" "NO")"
		-DVTK_MODULE_ENABLE_VTK_IOSQL="YES" # sqlite
		-DVTK_MODULE_ENABLE_VTK_IOPDAL="$(usex pdal "YES" "NO")"
		-DVTK_MODULE_ENABLE_VTK_IOXML="YES"
		-DVTK_MODULE_ENABLE_VTK_IOXMLParser="YES"
		-DVTK_MODULE_ENABLE_VTK_RenderingFreeType="$(usex freetype "YES" "NO")"
		-DVTK_MODULE_ENABLE_VTK_RenderingFreeTypeFontConfig="$(usex freetype "YES" "NO")"
		-DVTK_MODULE_ENABLE_VTK_cgns="$(usex cgns "YES" "NO")"
		-DVTK_MODULE_ENABLE_VTK_doubleconversion="YES"
		-DVTK_MODULE_ENABLE_VTK_eigen="YES"
		-DVTK_MODULE_ENABLE_VTK_expat="YES"
		-DVTK_MODULE_ENABLE_VTK_fmt="YES"
		-DVTK_MODULE_ENABLE_VTK_freetype="YES"
		-DVTK_MODULE_ENABLE_VTK_hdf5="YES"
		-DVTK_MODULE_ENABLE_VTK_jpeg="YES"
		-DVTK_MODULE_ENABLE_VTK_jsoncpp="YES"
		-DVTK_MODULE_ENABLE_VTK_libharu="$(usex minimal "NO" "YES")"
		-DVTK_MODULE_ENABLE_VTK_libproj="YES"
		-DVTK_MODULE_ENABLE_VTK_libxml2="YES"
		-DVTK_MODULE_ENABLE_VTK_lz4="YES"
		-DVTK_MODULE_ENABLE_VTK_lzma="YES"
		-DVTK_MODULE_ENABLE_VTK_netcdf="$(usex netcdf "YES" "NO")"
		-DVTK_MODULE_ENABLE_VTK_nlohmannjson="YES"
		-DVTK_MODULE_ENABLE_VTK_ogg="YES"
		-DVTK_MODULE_ENABLE_VTK_pegtl="YES"
		-DVTK_MODULE_ENABLE_VTK_png="YES"
		-DVTK_MODULE_ENABLE_VTK_pugixml="YES"
		-DVTK_MODULE_ENABLE_VTK_sqlite="YES"
		-DVTK_MODULE_ENABLE_VTK_theora="$(usex minimal "NO" "YES")"
		-DVTK_MODULE_ENABLE_VTK_tiff="YES"
		-DVTK_MODULE_ENABLE_VTK_utf8="YES"
		-DVTK_MODULE_ENABLE_VTK_vtkvtkm="$(usex vtkm "YES" "NO")"
		-DVTK_MODULE_ENABLE_VTK_zlib="YES"

		# not packaged in Gentoo
		-DVTK_MODULE_USE_EXTERNAL_VTK_fast_float=OFF
		-DVTK_MODULE_USE_EXTERNAL_VTK_exprtk=OFF
		-DVTK_MODULE_USE_EXTERNAL_VTK_ioss=OFF
		-DVTK_MODULE_USE_EXTERNAL_VTK_verdict=OFF

		-DVTK_RELOCATABLE_INSTALL=ON
		-DVTK_UNIFIED_INSTALL_TREE=ON

		-DVTK_SMP_ENABLE_OPENMP="$(usex openmp)"
		-DVTK_SMP_ENABLE_STDTHREAD="$(usex threads)"
		-DVTK_SMP_ENABLE_TBB="$(usex tbb)"

		-DVTK_USE_CUDA="$(usex cuda)"
		# use system libraries where possible
		-DVTK_USE_EXTERNAL=ON
		# avoid finding package from either ::guru or ::sci
		-DVTK_USE_MEMKIND=OFF
		-DVTK_USE_MPI="$(usex mpi)"
		-DVTK_USE_TK="$(usex tk)"
		-DVTK_USE_X=ON

		-DVTK_WHEEL_BUILD=OFF

		-DVTK_WRAP_JAVA="$(usex java)"
		-DVTK_WRAP_PYTHON="$(usex python)"
	)

	if use all-modules; then
		mycmakeargs+=(
			# no package in ::gentoo
			-DVTK_ENABLE_OSPRAY=OFF
			# TODO: some of these are tied to the VTK_ENABLE_REMOTE_MODULES
			# option. Check whether we can download them clean and enable
			# them.
			-DVTK_MODULE_ENABLE_VTK_DomainsMicroscopy="NO"
			-DVTK_MODULE_ENABLE_VTK_fides="NO"
			-DVTK_MODULE_ENABLE_VTK_FiltersOpenTURNS="NO"
			-DVTK_MODULE_ENABLE_VTK_IOADIOS2="NO"
			-DVTK_MODULE_ENABLE_VTK_IOFides="NO"

			-DVTK_MODULE_ENABLE_VTK_RenderingOpenVR="NO"
			-DVTK_MODULE_ENABLE_VTK_RenderingOpenXR="NO"

			-DVTK_MODULE_USE_EXTERNAL_VTK_cli11="YES"
		)
	fi

	if use boost; then
		mycmakeargs+=(
			-DVTK_MODULE_ENABLE_VTK_InfovisBoost="YES"
			-DVTK_MODULE_ENABLE_VTK_InfovisBoostGraphAlgorithms="YES"
		)
	fi

	if use cuda; then
		cuda_add_sandbox -w
		addwrite "/proc/self/task"

		if ! test -w /dev/nvidiactl; then
			# eqawarn "Can't access the GPU at /dev/nvidiactl."
			# eqawarn "User $(id -nu) is not in the group \"video\"."
			if [[ -z "${CUDA_GENERATION}" ]] && [[ -z "${CUDA_ARCH_BIN}" ]]; then
				# build all targets
				mycmakeargs+=(
					-DCUDA_GENERATION=""
				)
			fi
		else
			local -x CUDAARCHS
			: "${CUDAARCHS:="$(cuda_get_host_native_arch)"}"
		fi

		# set NVCC_CCBIN
		local -x CUDAHOSTCXX CUDAHOSTLD
		CUDAHOSTCXX="$(cuda_get_host_compiler)"
		CUDAHOSTLD="$(tc-getCXX)"
		export NVCC_CCBIN="${CUDAHOSTCXX}"

		if tc-is-gcc; then
			# Filter out IMPLICIT_LINK_DIRECTORIES picked up by CMAKE_DETERMINE_COMPILER_ABI(CUDA)
			# See /usr/share/cmake/Help/variable/CMAKE_LANG_IMPLICIT_LINK_DIRECTORIES.rst
			CMAKE_CUDA_IMPLICIT_LINK_DIRECTORIES_EXCLUDE=$(
				"${CUDAHOSTLD}" -E -v - <<<"int main(){}" |& \
				grep LIBRARY_PATH | cut -d '=' -f 2 | cut -d ':' -f 1
			)
		fi
	fi

	if use debug; then
		mycmakeargs+=(
			-DVTK_DEBUG_LEAKS=ON
			-DVTK_DEBUG_MODULE=ON
			-DVTK_DEBUG_MODULE_ALL=ON
			-DVTK_ENABLE_SANITIZER=ON
			-DVTK_EXTRA_COMPILER_WARNINGS=ON
			-DVTK_WARN_ON_DISPATCH_FAILURE=ON
		)
		if use rendering; then
			mycmakeargs+=( -DVTK_OPENGL_ENABLE_STREAM_ANNOTATIONS=ON )
		fi
	else
		: "${CMAKE_BUILD_TYPE:="Release"}"
		export CMAKE_BUILD_TYPE
	fi

	if use examples || use test; then
		mycmakeargs+=( -DVTK_USE_LARGE_DATA=ON )
	fi

	if use ffmpeg; then
		mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_IOFFMPEG="YES" )
		if use rendering; then
			mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_RenderingFFMPEGOpenGL2="YES" )
		fi
	fi

	if use gdal; then
		mycmakeargs+=(
			-DVTK_MODULE_ENABLE_VTK_GeovisGDAL="YES"
			-DVTK_MODULE_ENABLE_VTK_IOGDAL="YES"
			-DVTK_MODULE_ENABLE_VTK_IOGeoJSON="YES"
		)
	fi

	if use imaging; then
		mycmakeargs+=(
			-DVTK_MODULE_ENABLE_VTK_ImagingColor="YES"
			-DVTK_MODULE_ENABLE_VTK_ImagingCore="YES"
			-DVTK_MODULE_ENABLE_VTK_ImagingFourier="YES"
			-DVTK_MODULE_ENABLE_VTK_ImagingGeneral="YES"
			-DVTK_MODULE_ENABLE_VTK_ImagingHybrid="YES"
			-DVTK_MODULE_ENABLE_VTK_ImagingMath="YES"
			-DVTK_MODULE_ENABLE_VTK_ImagingMorphological="YES"
			-DVTK_MODULE_ENABLE_VTK_ImagingOpenGL2="YES"
			-DVTK_MODULE_ENABLE_VTK_ImagingSources="YES"
			-DVTK_MODULE_ENABLE_VTK_ImagingStatistics="YES"
			-DVTK_MODULE_ENABLE_VTK_ImagingStencil="YES"
		)
		use rendering && mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_RenderingImage="YES" )
	fi

	if ! use java && ! use python; then
		# defaults to ON
		mycmakeargs+=( -DVTK_ENABLE_WRAPPING=OFF )
	fi

	if use java; then
		mycmakeargs+=(
			-DCMAKE_INSTALL_JARDIR="share/${PN}"
			-DVTK_ENABLE_WRAPPING=ON
			-DVTK_MODULE_ENABLE_VTK_Java="YES"
			-DVTK_JAVA_SOURCE_VERSION="$(java-config -g PROVIDES_VERSION)"
			-DVTK_JAVA_TARGET_VERSION="$(java-config -g PROVIDES_VERSION)"
		)
	fi

	if use minimal; then
		mycmakeargs+=(
			-DVTK_MODULE_ENABLE_VTK_CommonComputationalGeometry="YES"
			-DVTK_MODULE_ENABLE_VTK_CommonExecutionModel="YES"
			-DVTK_MODULE_ENABLE_VTK_CommonMath="YES"
			-DVTK_MODULE_ENABLE_VTK_CommonMisc="YES"
			-DVTK_MODULE_ENABLE_VTK_CommonSystem="YES"
			-DVTK_MODULE_ENABLE_VTK_CommonTransforms="YES"

			-DVTK_MODULE_ENABLE_VTK_FiltersCore="YES"
			-DVTK_MODULE_ENABLE_VTK_FiltersExtraction="YES"
			-DVTK_MODULE_ENABLE_VTK_FiltersGeneral="YES"
			-DVTK_MODULE_ENABLE_VTK_FiltersGeneric="YES"
			-DVTK_MODULE_ENABLE_VTK_FiltersGeometry="YES"
			-DVTK_MODULE_ENABLE_VTK_FiltersHybrid="NO"
			-DVTK_MODULE_ENABLE_VTK_FiltersHyperTree="YES"
			-DVTK_MODULE_ENABLE_VTK_FiltersSources="YES"
			-DVTK_MODULE_ENABLE_VTK_FiltersStatistics="YES"
			-DVTK_MODULE_ENABLE_VTK_FiltersVerdict="YES"

			-DVTK_MODULE_ENABLE_VTK_IOCore="YES"
			-DVTK_MODULE_ENABLE_VTK_IOGeometry="NO"
			-DVTK_MODULE_ENABLE_VTK_IOLegacy="YES"

			-DVTK_MODULE_ENABLE_VTK_ParallelCore="YES"
			-DVTK_MODULE_ENABLE_VTK_ParallelDIY="YES"
		)
	fi

	if use mpi; then
		mycmakeargs+=(
			-DVTK_GROUP_ENABLE_MPI="YES"
			-DVTK_MODULE_ENABLE_VTK_IOH5part="YES"
			-DVTK_MODULE_ENABLE_VTK_IOMPIParallel="YES"
			-DVTK_MODULE_ENABLE_VTK_IOParallel="YES"
			-DVTK_MODULE_ENABLE_VTK_IOParallelNetCDF="$(usex netcdf "YES" "NO")"
			-DVTK_MODULE_ENABLE_VTK_IOParallelXML="YES"
			-DVTK_MODULE_ENABLE_VTK_ParallelMPI="YES"
			-DVTK_MODULE_ENABLE_VTK_h5part="YES"
			-DVTK_MODULE_USE_EXTERNAL_VTK_verdict=OFF
		)
		use imaging && mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_IOMPIImage="YES" )
		use python && mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_ParallelMPI4Py="YES" )
		if use rendering; then
			mycmakeargs+=(
				-DVTK_MODULE_ENABLE_VTK_RenderingParallel="YES"
				-DVTK_MODULE_ENABLE_VTK_RenderingParallelLIC="YES"
			)
		fi
		use vtkm && mycmakeargs+=( -DVTKm_ENABLE_MPI=ON )
	else
		mycmakeargs+=( -DVTK_GROUP_ENABLE_MPI="NO" )
	fi

	use mysql && mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_IOMySQL="YES" )
	use odbc && mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_IOODBC="YES" )
	use openvdb && mycmakeargs+=( -DOpenVDB_CMAKE_PATH="${ESYSROOT}/usr/$(get_libdir)/cmake/OpenVDB" )
	use postgres && mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_IOPostgreSQL="YES" )

	if use python; then
		mycmakeargs+=(
			-DPython3_EXECUTABLE="${PYTHON}"
			-DVTK_ENABLE_WRAPPING=ON
			-DVTK_MODULE_ENABLE_VTK_Python="YES"
			-DVTK_MODULE_ENABLE_VTK_PythonInterpreter="YES"
			-DVTK_MODULE_ENABLE_VTK_WrappingPythonCore="YES"
			-DVTK_PYTHON_OPTIONAL_LINK="OFF"
			-DVTK_PYTHON_SITE_PACKAGES_SUFFIX="lib/${EPYTHON}/site-packages"
		)
		use rendering && mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_PythonContext2D="YES" )
	fi

	if use qt6; then
		mycmakeargs+=(
			-DCMAKE_INSTALL_QMLDIR="${EPFREIX}/usr/$(get_libdir)/qt6/qml"
			-DVTK_QT_VERSION="6"
		)
		if has_version "dev-qt/qtbase:6[gles2-only]" || use gles2-only; then
			mycmakeargs+=(
				# Force using EGL & GLES
				-DVTK_OPENGL_HAS_EGL=ON
				-DVTK_OPENGL_USE_GLES=ON
			)
		fi
	else
		mycmakeargs+=( -DVTK_GROUP_ENABLE_Qt="NO" )
	fi

	if use qt6; then
		mycmakeargs+=(
			-DVTK_GROUP_ENABLE_Qt:STRING="YES"
			-DVTK_MODULE_ENABLE_VTK_GUISupportQt="YES"
			-DVTK_MODULE_ENABLE_VTK_GUISupportQtQuick="YES"
		)
		if use mysql || use postgres; then
			mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_GUISupportQtSQL="YES" )
		fi
		if use rendering; then
			mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_RenderingQt="YES" )
		fi
		if use views; then
			mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_ViewsQt="YES" )
		fi
	fi

	if use rendering; then
		mycmakeargs+=(
			-DVTK_ENABLE_OSPRAY=OFF

			-DVTK_MODULE_ENABLE_VTK_IOExportGL2PS="YES"
			-DVTK_MODULE_ENABLE_VTK_RenderingAnnotation="YES"
			-DVTK_MODULE_ENABLE_VTK_RenderingContext2D="YES"
			-DVTK_MODULE_ENABLE_VTK_RenderingContextOpenGL2="YES"
			-DVTK_MODULE_ENABLE_VTK_RenderingCore="YES"
			-DVTK_MODULE_ENABLE_VTK_RenderingExternal="YES"
			-DVTK_MODULE_ENABLE_VTK_RenderingGL2PSOpenGL2="YES"
			-DVTK_MODULE_ENABLE_VTK_RenderingHyperTreeGrid="YES"
			-DVTK_MODULE_ENABLE_VTK_RenderingLICOpenGL2="YES"
			-DVTK_MODULE_ENABLE_VTK_RenderingLOD="YES"
			-DVTK_MODULE_ENABLE_VTK_RenderingLabel="YES"
			-DVTK_MODULE_ENABLE_VTK_RenderingOpenGL2="YES"
			-DVTK_MODULE_ENABLE_VTK_RenderingRayTracing="YES"
			-DVTK_MODULE_ENABLE_VTK_RenderingSceneGraph="YES"
			-DVTK_MODULE_ENABLE_VTK_RenderingUI="YES"
			-DVTK_MODULE_ENABLE_VTK_RenderingVolume="YES"
			-DVTK_MODULE_ENABLE_VTK_RenderingVolumeAMR="YES"
			-DVTK_MODULE_ENABLE_VTK_RenderingVolumeOpenGL2="YES"
			-DVTK_MODULE_ENABLE_VTK_RenderingZSpace="NO"
			-DVTK_MODULE_ENABLE_VTK_gl2ps="YES"
			-DVTK_MODULE_ENABLE_VTK_glew="YES"
			-DVTK_MODULE_ENABLE_VTK_opengl="YES"

			-DVTK_USE_SDL2="$(usex sdl "YES" "NO")"
		)
		use python && mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_RenderingMatplotlib="YES" )
		use tk && mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_RenderingTk="YES" )
		use views && mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_ViewsContext2D="YES" )
		use web && mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_RenderingVtkJS="YES" )
	fi

	# Testing has been changed in 9.2.5: it is now allowed without
	# requiring to download, if the data files are available locally!
	if use test; then
		mycmakeargs+=(
			-DVTK_BUILD_TESTING=ON
			# disable fetching data files for the default 'all' target
			-DVTK_DATA_EXCLUDE_FROM_ALL=OFF

			# requested even if all use flags are off
			-DVTK_MODULE_ENABLE_VTK_octree="YES"
			-DVTK_MODULE_ENABLE_VTK_ViewsCore="YES"

			-DVTK_MODULE_USE_EXTERNAL_VTK_cli11="YES"
		)
	else
		mycmakeargs+=( -DVTK_BUILD_TESTING=OFF )
	fi

	# FIXME: upstream provides 4 threading models, as of 9.1.0. These are
	# sequential, stdthread, openmp and tbb. AFAICS all of them can be
	# enabled at the same time. Sequential and STDThread are enabled by
	# default. The default selected type for the build is sequential.
	# Assuming sequential < STDThread < openmp < tbb wrt speed, although
	# this is dependent on the actual scenario where threading is used.
	if use tbb; then
		mycmakeargs+=( -DVTK_SMP_IMPLEMENTATION_TYPE="TBB" )
	elif use openmp; then # FIXME doesn't work with clang
		mycmakeargs+=( -DVTK_SMP_IMPLEMENTATION_TYPE="OpenMP" )
	elif use threads; then
		mycmakeargs+=( -DVTK_SMP_IMPLEMENTATION_TYPE="STDThread" )
	else
		mycmakeargs+=( -DVTK_SMP_IMPLEMENTATION_TYPE="Sequential" )
	fi

	use tk && mycmakeargs+=( -DVTK_GROUP_ENABLE_Tk="YES" )

	if use views; then
		mycmakeargs+=(
			-DVTK_MODULE_ENABLE_VTK_ViewsCore="YES"
			-DVTK_MODULE_ENABLE_VTK_ViewsInfovis="YES"
		)
	fi

	if use vtkm; then
		mycmakeargs+=(
			-DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKmCore="YES"
			-DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKmDataModel="YES"
			-DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKmFilters="YES"
			-DVTKm_ENABLE_CPACK="no" # "Enable CPack packaging of VTKm" ON
			-DVTKm_ENABLE_CUDA="$(usex cuda)" # "Enable Cuda support" OFF
			-DVTKm_ENABLE_DOCUMENTATION="$(usex doc)" # "Build Doxygen documentation" OFF
			-DVTKm_ENABLE_EXAMPLES="$(usex examples)" # "Build examples" OFF
			-DVTKm_ENABLE_HDF5_IO="yes" # "Enable HDF5 support" OFF
			-DVTKm_ENABLE_LOGGING="$(usex logging)" # "Enable VTKm Logging" ON
			-DVTKm_ENABLE_MPI="$(usex mpi)" # "Enable MPI support" OFF
			-DVTKm_ENABLE_OPENMP="$(usex openmp)" # "Enable OpenMP support" OFF
			-DVTKm_ENABLE_RENDERING="$(usex rendering)" # "Enable rendering library" ON
			-DVTKm_ENABLE_TBB="$(usex tbb)" # "Enable TBB support" OFF
			-DVTKm_ENABLE_TESTING="$(usex test)" # "Enable VTKm Testing" ON
			-DVTKm_ENABLE_TUTORIALS="no" # "Build tutorials" OFF
			-DVTKm_NO_ASSERT_CUDA="yes" # "Disable assertions for CUDA devices." ON
			-DVTKm_NO_ASSERT_HIP="yes" # "Disable assertions for HIP devices." ON
			-DVTKm_NO_ASSERT="no" # "Disable assertions in debugging builds." OFF
			-DVTKm_NO_INSTALL_README_LICENSE="ON" # bug #793221 # "disable the installation of README and LICENSE files" OFF
			-DVTKm_SKIP_LIBRARY_VERSIONS="no" # "Skip versioning VTK-m libraries" OFF
			-DVTKm_Vectorization="none" # only sets compiler flags
		)
	fi

	if use web; then
		mycmakeargs+=(
			-DVTK_MODULE_ENABLE_VTK_WebCore="YES"
			-DVTK_MODULE_ENABLE_VTK_WebGLExporter="YES"
		)
		use python && mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_WebPython="YES" )
	fi

	cmake_src_configure
}

src_compile() {
	use test && cmake_build VTKData
	cmake_src_compile
}

src_test() {
	vtk_add_sandbox

	# don't work at all
	REALLY_BAD_TESTS=(
		"VTK::RenderingRayTracing-HeaderTest$" # (Failed)                                                          #   82
		"VTK::RenderingFreeTypeFontConfigCxx-TestSystemFontRendering$" # (Failed)                                  #  309
		"VTK::IOMPIParallelPython-MPI-Plot3DMPIIO$" # (Failed)                                                     #  376
		"VTK::IOExportPDFCxx-TestPDFTransformedText-VerifyRasterizedPDFPNG$" # (Failed)                            #  483
		# "VTK::IOExportGL2PSCxx-TestGL2PSExporterVolumeRaster$" # (Failed)                                          #  494
		# "VTK::IOExportGL2PSCxx-TestGL2PSExporterVolumeRaster-VerifyRasterizedPNG$" # (Failed)                      #  518
		# "VTK::IOExportGL2PSCxx-TestGL2PSExporterVolumeRaster-VerifyRasterizedPDFPNG$" # (Failed)                   #  519
		"VTK::GUISupportQtQuickCxx-TestQQuickVTKRenderItem$" # (Failed)                                            #  732
		"VTK::GUISupportQtQuickCxx-TestQQuickVTKRenderItemWidget$" # (Failed)                                      #  733
		"VTK::GUISupportQtQuickCxx-TestQQuickVTKRenderWindow$" # (Failed)                                          #  734
		"VTK::FiltersSelectionCxx-TestLinearSelector3D$" # (Failed)                                                # 1102
		"VTK::FiltersParallelDIY2Cxx-MPI-TestProbeLineFilter$" # (Failed)                                          # 1180
		"VTK::FiltersFlowPathsCxx-TestEvenlySpacedStreamlines2D$" # (Failed)                                       # 1215
		"VTK::ChartsCoreCxx-TestChartDoubleColors$" # (Failed)                                                     # 1555
		"VTK::ChartsCoreCxx-TestChartDoubleColorsOpaque$" # (Failed)                                               # 1556
		"VTK::ChartsCoreCxx-TestParallelCoordinatesDouble$" # (Failed)                                             # 1599
		"VTK::AcceleratorsVTKmFiltersCxx-TestVTKMExternalFaces$" # (Failed)                                        # 2142
		"VTK::AcceleratorsVTKmFiltersCxx-TestVTKMHistogram$" # (Failed)                                            # 2146
		"VTK::AcceleratorsVTKmFiltersCxx-TestVTKMMarchingCubes$" # (Failed)                                        # 2148
		"VTK::AcceleratorsVTKmFiltersCxx-TestVTKMMarchingCubes2$" # (Failed)                                       # 2149
		"VTK::FiltersGeneralCxx-TestContourTriangulatorHoles$" # (Failed)                                          # 2305
		"VTK::FiltersCoreCxx-TestDecimatePolylineFilter$" # (Failed)                                               # 2497
		"VTK::FiltersCorePython-TestSphereTreeFilter$" # (Failed)                                                  # 2617
		"VTK::CommonDataModelCxx-TestTriangle$" # (Failed)                                                         # 2770
		"VTK::CommonDataModelCxx-UnitTestCells$" # (Failed)                                                        # 2793
		"VTK::CommonDataModelCxx-TestHyperTreeGridGeometricLocator$" # (Failed)                                    # 2799
	)

	# don't work in src_test but when on their own
	BAD_TESTS=(
		"VTK::IOMotionFXCxx-TestMotionFXCFGReaderPositionFile$" # (Subprocess aborted)                             #  374

		# "VTK::IOExportGL2PSCxx-TestGL2PSExporterVolumeRaster-RasterizePNG$" # (Not Run)                            #  517

		"VTK::FiltersParallelDIY2Cxx-MPI-TestGhostCellsGenerator$" # (Timeout)                                     # 1173
		"VTK::FiltersParallelDIY2Cxx-MPI-TestRedistributeDataSetFilterOnIOSS$" # (Timeout)                         # 1185
		"VTK::FiltersParallelDIY2Cxx-TestOverlappingCellsDetector$" # (Timeout)                                    # 1193
		"VTK::FiltersParallelDIY2Cxx-TestRedistributeDataSetFilter$" # (Timeout)                                   # 1196
		"VTK::FiltersParallelDIY2Cxx-TestRedistributeDataSetFilterOnIOSS$" # (Timeout)                             # 1197
		"VTK::FiltersParallelDIY2Cxx-TestRedistributeDataSetFilterWithPolyData$" # (Timeout)                       # 1198
		"VTK::CommonCoreCxx-TestSMP$"                                                                              # 2945

		# "VTK::IOMovieCxx-TestAVIWriter$" # (Skipped)                                                               #  470
		# "VTK::IOMovieCxx-TestMP4Writer$" # (Skipped)                                                               #  471

		"VTK::RenderingMatplotlibCxx-TestContextMathTextImage$" # (NUMERICAL)                                      #  243
		"VTK::RenderingMatplotlibCxx-TestMathTextActor$" # (NUMERICAL)                                             #  244
		"VTK::RenderingMatplotlibCxx-TestMathTextActor3D$" # (NUMERICAL)                                           #  245
		"VTK::RenderingMatplotlibCxx-TestRenderString$" # (NUMERICAL)                                              #  246
		"VTK::RenderingMatplotlibCxx-TestStringToPath$" # (NUMERICAL)                                              #  247
		"VTK::RenderingMatplotlibCxx-TestIndexedLookupScalarBar$" # (NUMERICAL)                                    #  248
		"VTK::RenderingMatplotlibCxx-TestScalarBarCombinatorics$" # (NUMERICAL)                                    #  249
		"VTK::RenderingLICOpenGL2Cxx-TestImageDataLIC2D$" # (NUMERICAL)                                            #  266
		"VTK::RenderingLICOpenGL2Cxx-TestStructuredGridLIC2DXSlice$" # (NUMERICAL)                                 #  267
		"VTK::RenderingLICOpenGL2Cxx-TestStructuredGridLIC2DYSlice$" # (NUMERICAL)                                 #  268
		"VTK::RenderingLICOpenGL2Cxx-TestStructuredGridLIC2DZSlice$" # (NUMERICAL)                                 #  269
		"VTK::RenderingLICOpenGL2Cxx-SurfaceLICCurvedDefaults$" # (NUMERICAL)                                      #  270
		"VTK::RenderingLICOpenGL2Cxx-SurfaceLICCurvedContrastEnhancedBlended$" # (NUMERICAL)                       #  271
		"VTK::RenderingLICOpenGL2Cxx-SurfaceLICCurvedContrastEnhancedMapped$" # (NUMERICAL)                        #  272
		"VTK::RenderingLICOpenGL2Cxx-SurfaceLICCurvedEnhancedVectorNormalizeOff$" # (NUMERICAL)                    #  273
		"VTK::RenderingLICOpenGL2Cxx-SurfaceLICCurvedContrastEnhancedBlendedSmallGrain$" # (NUMERICAL)             #  274
		"VTK::RenderingLICOpenGL2Cxx-SurfaceLICCurvedContrastEnhancedMappedSmallGrain$" # (NUMERICAL)              #  275
		"VTK::RenderingLICOpenGL2Cxx-SurfaceLICCurvedContrastEnhancedMappedSmallVectorNormalizeOff$" # (NUMERICAL) #  276
		"VTK::RenderingLICOpenGL2Cxx-SurfaceLICCurvedDefaultsColor$" # (NUMERICAL)                                 #  277
		"VTK::RenderingLICOpenGL2Cxx-SurfaceLICCurvedContrastEnhancedColorBlendedSmallGrain$" # (NUMERICAL)        #  278
		"VTK::RenderingLICOpenGL2Cxx-SurfaceLICCurvedContrastEnhancedColorMappedSmallGrain$" # (NUMERICAL)         #  279
		"VTK::RenderingLICOpenGL2Cxx-SurfaceLICCurvedContrastEnhancedColorBlendedSmallGrainMask$" # (NUMERICAL)    #  280
		"VTK::RenderingLICOpenGL2Cxx-SurfaceLICCurvedContrastEnhancedColorMappedSmallGrainMask$" # (NUMERICAL)     #  281
		"VTK::RenderingLICOpenGL2Cxx-SurfaceLICCurvedContrastEnhancedSmallGrainMask$" # (NUMERICAL)                #  282
		"VTK::RenderingLICOpenGL2Cxx-SurfaceLICPlanarDefaults$" # (NUMERICAL)                                      #  283
		"VTK::RenderingLICOpenGL2Cxx-SurfaceLICPlanarContrastEnhanced$" # (NUMERICAL)                              #  284
		"VTK::RenderingLICOpenGL2Cxx-SurfaceLICPlanarVectorNormalizeOff$" # (NUMERICAL)                            #  285
		"VTK::RenderingLICOpenGL2Cxx-SurfaceLICPlanarVectorNormalizeOffMediumGrainUniform$" # (NUMERICAL)          #  286
		"VTK::RenderingLICOpenGL2Cxx-SurfaceLICPlanarVectorNormalizeOffMediumGrainPerlin$" # (NUMERICAL)           #  287
		"VTK::RenderingLICOpenGL2Cxx-SurfaceLICMultiBlockContrastEnhancedPerlin$" # (NUMERICAL)                    #  288
		"VTK::RenderingExternalCxx-TestGLUTRenderWindow$" # (Failed)                                               #  311
		"VTK::ImagingOpenGL2Cxx-TestOpenGLImageGradient$" # (NUMERICAL)                                            #  722
		# "VTK::InteractionWidgetsCxx-TestPickingManagerSeedWidget$" # (Timeout)                                     #  838
		"VTK::InteractionWidgetsCxx-TestResliceCursorWidget2$" # (Failed)                                          #  847
		"VTK::InteractionWidgetsCxx-TestResliceCursorWidget3$" # (Failed)                                          #  848
		"VTK::InteractionWidgetsPython-TestTensorWidget2$" # (Failed)                                              #  919
		# "VTK::FiltersModelingPython-TestCookieCutter4$" # (Timeout)                                                # 1319
		"VTK::RenderingOpenGL2Cxx-TestGlyph3DMapperPickability$" # (Failed)                                        # 1404
		"VTK::RenderingCoreCxx-TestTextureRGBADepthPeeling$" # (Failed)                                            # 2020
		"VTK::AcceleratorsVTKmFiltersCxx-TestVTKMCleanGrid$" # (NUMERICAL)                                         # 2138
		"VTK::AcceleratorsVTKmFiltersCxx-TestVTKMClip$" # (NUMERICAL)                                              # 2140
		"VTK::AcceleratorsVTKmFiltersCxx-TestVTKMClipWithImplicitFunction$" # (NUMERICAL)                          # 2141
		"VTK::AcceleratorsVTKmFiltersCxx-TestVTKMExtractVOI$" # (NUMERICAL)                                        # 2143
		"VTK::AcceleratorsVTKmFiltersCxx-TestVTKMLevelOfDetail$" # (NUMERICAL)                                     # 2147
		"VTK::AcceleratorsVTKmFiltersCxx-TestVTKMPointElevation$" # (NUMERICAL)                                    # 2152
		"VTK::AcceleratorsVTKmFiltersCxx-TestVTKMPointTransform$" # (NUMERICAL)                                    # 2153
		"VTK::AcceleratorsVTKmFiltersCxx-TestVTKMPolyDataNormals$" # (NUMERICAL)                                   # 2155
		"VTK::AcceleratorsVTKmFiltersCxx-TestVTKMThreshold$" # (NUMERICAL)                                         # 2157
		"VTK::AcceleratorsVTKmFiltersCxx-TestVTKMThreshold2$" # (NUMERICAL)                                        # 2158
		"VTK::AcceleratorsVTKmFiltersCxx-TestVTKMTriangleMeshPointNormals$" # (NUMERICAL)                          # 2159
		"VTK::AcceleratorsVTKmFiltersCxx-TestVTKMWarpScalar$" # (NUMERICAL)                                        # 2160
		"VTK::AcceleratorsVTKmFiltersCxx-TestVTKMWarpVector$" # (NUMERICAL)                                        # 2161
		"VTK::AcceleratorsVTKmCoreCxx-TestVTKMImplicitDataArray$" # (NUMERICAL)                                    # 2897
	)

	SEQUENTIAL_TESTS=(
		# TODO requires die -n
		# "VTK::IOExportGL2PSCxx-.*$"
		"VTK::IOExportGL2PSCxx-TestGL2PSBillboardTextActor3D$"
		"VTK::IOExportGL2PSCxx-TestGL2PSContext$"
		"VTK::IOExportGL2PSCxx-TestGL2PSLabeledDataMapper$"
		"VTK::IOExportGL2PSCxx-TestGL2PSScalarBar$"
		"VTK::IOExportGL2PSCxx-TestGL2PSTextActor3D$"
		"VTK::IOExportGL2PSCxx-TestGL2PSTextActor$"
		"VTK::IOExportGL2PSCxx-TestGL2PSTextMapper$"
		"VTK::IOExportGL2PSCxx-TestStackedPlotGL2PS$"
		"VTK::IOExportGL2PSCxx-TestGL2PSExporterMultipleRenderers$"
		"VTK::IOExportGL2PSCxx-TestGL2PSExporterRaster$"
		# "VTK::IOExportGL2PSCxx-TestGL2PSExporterVolumeRaster$" # (Failed)                                          #  494
		"VTK::IOExportGL2PSCxx-TestGL2PSBillboardTextActor3D-RasterizePNG$"
		"VTK::IOExportGL2PSCxx-TestGL2PSBillboardTextActor3D-VerifyRasterizedPNG$"
		"VTK::IOExportGL2PSCxx-TestGL2PSContext-RasterizePNG$"
		"VTK::IOExportGL2PSCxx-TestGL2PSContext-VerifyRasterizedPNG$"
		"VTK::IOExportGL2PSCxx-TestGL2PSLabeledDataMapper-RasterizePNG$"
		"VTK::IOExportGL2PSCxx-TestGL2PSLabeledDataMapper-VerifyRasterizedPNG$"
		"VTK::IOExportGL2PSCxx-TestGL2PSScalarBar-RasterizePNG$"
		"VTK::IOExportGL2PSCxx-TestGL2PSScalarBar-VerifyRasterizedPNG$"
		"VTK::IOExportGL2PSCxx-TestGL2PSTextActor3D-RasterizePNG$"
		"VTK::IOExportGL2PSCxx-TestGL2PSTextActor3D-VerifyRasterizedPNG$"
		"VTK::IOExportGL2PSCxx-TestGL2PSTextActor-RasterizePNG$"
		"VTK::IOExportGL2PSCxx-TestGL2PSTextActor-VerifyRasterizedPNG$"
		"VTK::IOExportGL2PSCxx-TestGL2PSTextMapper-RasterizePNG$"
		"VTK::IOExportGL2PSCxx-TestGL2PSTextMapper-VerifyRasterizedPNG$"
		"VTK::IOExportGL2PSCxx-TestStackedPlotGL2PS-RasterizePNG$"
		"VTK::IOExportGL2PSCxx-TestStackedPlotGL2PS-VerifyRasterizedPNG$"
		"VTK::IOExportGL2PSCxx-TestGL2PSExporterMultipleRenderers-RasterizePNG$"
		"VTK::IOExportGL2PSCxx-TestGL2PSExporterMultipleRenderers-VerifyRasterizedPNG$"
		"VTK::IOExportGL2PSCxx-TestGL2PSExporterMultipleRenderers-VerifyRasterizedPDFPNG$"
		"VTK::IOExportGL2PSCxx-TestGL2PSExporterRaster-RasterizePNG$"
		"VTK::IOExportGL2PSCxx-TestGL2PSExporterRaster-VerifyRasterizedPNG$"
		"VTK::IOExportGL2PSCxx-TestGL2PSExporterRaster-VerifyRasterizedPDFPNG$"
		# "VTK::IOExportGL2PSCxx-TestGL2PSExporterVolumeRaster-RasterizePNG$" # (Not Run)                            #  517
		# "VTK::IOExportGL2PSCxx-TestGL2PSExporterVolumeRaster-VerifyRasterizedPNG$" # (Failed)                      #  518
		# "VTK::IOExportGL2PSCxx-TestGL2PSExporterVolumeRaster-VerifyRasterizedPDFPNG$" # (Failed)                   #  519
		"VTK::InteractionWidgetsCxx-TestPickingManagerSeedWidget$" # (Timeout)                                     #  838
		"VTK::FiltersModelingPython-TestCookieCutter4$" # (Timeout)                                                # 1319
	)

	CMAKE_SKIP_TESTS=(
		"${BAD_TESTS[@]}"
		"${REALLY_BAD_TESTS[@]}"
		"${SEQUENTIAL_TESTS[@]}"
	)

	virtx cmake_src_test
	unset CMAKE_SKIP_TESTS

	myctestargs=(
		-R "($( IFS='|'; echo "${SEQUENTIAL_TESTS[*]}"))"
		-j1
	)
	# TODO requires die -n
	# nonfatal \
		virtx cmake_src_test || einfo "These tests are known to fail"

	# TODO requires die -n
	# myctestargs=(
	# 	-R "($( IFS='|'; echo "${REALLY_BAD_TESTS[*]}"))"
	# 	--timeout 600
	# )
	# nonfatal \
	# 	virtx cmake_src_test || einfo "These tests are known to fail"

	# TODO requires die -n
	# myctestargs=(
	# 	-R "($( IFS='|'; echo "${BAD_TESTS[*]}"))"
	# 	--timeout 600
	# )
	# nonfatal \
	# 	virtx cmake_src_test || einfo "These tests are known to only fail inside src_test"
}

src_install() {
	use web && webapp_src_preinst

	# Stop web page images from being compressed
	if use doc; then
		HTML_DOCS=( "${WORKDIR}/html/." )
	fi

	cmake_src_install

	use java && java-pkg_regjar "${ED}/usr/share/${PN}/${PN}.jar"

	# install examples
	if use examples; then
		einfo "Installing examples"
		mv -v {E,e}xamples || die
		dodoc -r examples
		docompress -x "/usr/share/doc/${PF}/examples"

		einfo "Installing datafiles"
		insinto "/usr/share/${PN}/data"
		doins -r "${S}/.ExternalData"
	fi

	use python && python_optimize

	use web && webapp_src_install
}

# webapp.eclass exports these but we want it optional #534036
pkg_postinst() {
	use web && webapp_pkg_postinst

	if use examples; then
		einfo "You can get more and updated examples at"
		einfo "https://kitware.github.io/vtk-examples/site/"
	fi
}

pkg_prerm() {
	use web && webapp_pkg_prerm
}
