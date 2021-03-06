#!/bin/sh

set -x
set -e

mkdir -p /tmp/syncplay-server/DEBIAN

echo "Package: syncplay-server
Version: "$(
  sed -n -e "s/^.*version = //p" syncplay/__init__.py | sed "s/'//g"
)$(
  if [ $(git describe --exact-match --tags HEAD | wc -l) = '0' ]; 
  then
    echo -git-$(date -u +%y%m%d%H%M)
  fi
)"
Architecture: all
Maintainer: <dev@syncplay.pl>
Depends: python3 (>= 3.6), python3-twisted (>= 16.4.0), python3-certifi
Conflicts: syncplay
Homepage: https://syncplay.pl
Section: web
Priority: optional
Description: Server only package.
 Solution to synchronize video playback across multiple instances of mpv, VLC, MPC-HC and MPC-BE over the Internet.
 Syncplay synchronises the position and play state of multiple media players so that the viewers can watch the same thing at the same time. This means that when one person pauses/unpauses playback or seeks (jumps position) within their media player then this will be replicated across all media players connected to the same server and in the same 'room' (viewing session). When a new person joins they will also be synchronised. Syncplay also includes text-based chat so you can discuss a video as you watch it (or you could use third-party Voice over IP software to talk over a video)." \
> /tmp/syncplay-server/DEBIAN/control
echo "#!/bin/sh
py3clean -p syncplay-server
"
> /tmp/syncplay-server/DEBIAN/prerm
chmod 555 /tmp/syncplay-server/DEBIAN/prerm

make install-server DESTDIR=/tmp/syncplay-server
dpkg -b /tmp/syncplay-server/
