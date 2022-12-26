# Start the APT-Cacher-NG Service
exec start-stop-daemon --start --chuid ${APT_CACHER_NG_USER}:${APT_CACHER_NG_USER} --exec "$(command -v apt-cacher-ng)" -- -c /etc/apt-cacher-ng