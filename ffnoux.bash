#!/bin/bash

set -eo pipefail

readonly url="${*}"
readonly wait=3

if [ -z "$(find /tmp -type d -name "firefox-??????" &>/dev/null | head -n 1)" ]; then
	readonly profile="$(mktemp -d /tmp/firefox-XXXXXX)"
	echo "first"
	echo "-------- $profile"
	# readonly first=true
	firefox \
		--headless \
		--new-instance \
		--first-startup \
		--profile "${profile}" \
		/dev/null \
		&>/dev/null &

	sleep "${wait}"

	kill %%

	echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >>${profile}/prefs.js

	mkdir "${profile}"/chrome

	cp ff.css "${profile}"/chrome/userChrome.css

else
	readonly profile="$(find /tmp -type d -name "firefox-??????" &>/dev/null | head -n 1)"
	echo "-------- $profile"
fi

echo "start ff $url -------- $profile"
firefox --new-instance --profile "${profile}" "${url}"
