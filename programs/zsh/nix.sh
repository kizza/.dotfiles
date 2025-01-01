# avoid macOS updates to destroy nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

[ -s ~/.nix-profile/etc/profile.d/nix.sh ] && \. ~/.nix-profile/etc/profile.d/nix.sh
