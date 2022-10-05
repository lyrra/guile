
_realname=guile3
pkgbase=mingw-w64-${_realname}
pkgname=("${MINGW_PACKAGE_PREFIX}-${_realname}")
pkgver=3.0.5
pkgrel=1
pkgdesc="guile3 (mingw-w64)"
arch=('any')
mingw_arch=('mingw64')
url='https://www.gnu.org/software/guile/'
license=('COPYING')
depends=("${MINGW_PACKAGE_PREFIX}-gc"
         "${MINGW_PACKAGE_PREFIX}-libiconv"
         "${MINGW_PACKAGE_PREFIX}-gcc-libs"
         "${MINGW_PACKAGE_PREFIX}-gettext"
         "${MINGW_PACKAGE_PREFIX}-libwinpthread-git"
         "${MINGW_PACKAGE_PREFIX}-libffi"
         "${MINGW_PACKAGE_PREFIX}-libunistring"
         )
makedepends=("${MINGW_PACKAGE_PREFIX}-autotools"
             "${MINGW_PACKAGE_PREFIX}-cc")
source=("https://github.com/lyrra/guile/archive/refs/heads/wip-mingw.tar.gz"
        #"0001-A-fix.patch"
       )
#sha256sums=('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
#            'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')

prepare() {
  echo prepare
}

build() {
  echo "----------- before build ------------"

  #cd "${srcdir}/${_realname}-${pkgver}"
  # cd "${srcdir}/$GITSRCDIR"
  # mkdir -p "${srcdir}/build-${MSYSTEM}" && cd "${srcdir}/build-${MSYSTEM}"
  # sh ../../build/ci/tools/configure_guile.sh
  # sh ../../build/ci/tools/build_guile.sh

}

check() {
  echo check
}

package() {
  echo package
  echo "install to dir pkgdir: ${pkgdir}"

  # since we build in guile's root-dir, no cd into build*
  #echo cd "${srcdir}/build-${MSYSTEM}"
  #cd "${srcdir}/build-${MSYSTEM}"
  cd ..
  echo "Current dir:"
  pwd
  ls -ltr
  make install DESTDIR="${pkgdir}"
}
