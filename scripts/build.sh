#!/bin/sh
set -eu

cd "$(dirname "$0")/.."

if [ -z "${SDL2_PREFIX:-}" ]; then
    if command -v sdl2-config >/dev/null 2>&1; then
        SDL2_PREFIX=$(sdl2-config --prefix)
    elif [ -d /opt/homebrew/opt/sdl2-compat ]; then
        SDL2_PREFIX=/opt/homebrew/opt/sdl2-compat
    elif [ -d /opt/homebrew/opt/sdl2 ]; then
        SDL2_PREFIX=/opt/homebrew/opt/sdl2
    elif [ -d /usr/local/opt/sdl2-compat ]; then
        SDL2_PREFIX=/usr/local/opt/sdl2-compat
    elif [ -d /usr/local/opt/sdl2 ]; then
        SDL2_PREFIX=/usr/local/opt/sdl2
    elif [ -d /opt/local/include/SDL2 ]; then
        SDL2_PREFIX=/opt/local
    else
        echo "SDL2 not found. Set SDL2_PREFIX to its installation prefix." >&2
        exit 1
    fi
fi
export SDL2_PREFIX

if [ ! -f "$SDL2_PREFIX/include/SDL2/SDL.h" ]; then
    echo "SDL2 headers not found under SDL2_PREFIX=$SDL2_PREFIX" >&2
    exit 1
fi

# Match the installed OS for local builds, rather than the SDK's version.
# Older deployment targets also require compatible dependencies and runtime.
MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET:-$(sw_vers -productVersion)}
export MACOSX_DEPLOYMENT_TARGET

exec alr build "$@" -- -cargs:Ada \
    "-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
