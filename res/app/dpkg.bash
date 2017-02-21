#!/bin/bash
myAppPath=$(dirname "$0")
exec "$myAppPath"/dpkg.exe "$@"
