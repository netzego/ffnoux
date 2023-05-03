#!/bin/bash
# shellcheck disable=SC2260,SC2155

# this might exit with errno 1. so we set $profile before activating strict mode for bash scripts
profile="$(find /tmp -type d -name "ffnoux-??????" &>/dev/null | head -n 1)"

# activate strict mode
set -eo pipefail

# on my machine a have to wait a bit; you might try it with wait=0
readonly wait=1
# part of the magic sauce
readonly css=$(
	cat <<EOF
/*
 * Do not remove the @namespace line -- it's required for correct functioning
 */
@namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul"); /* set default namespace to XUL */

/*
 * Hide tab bar, navigation bar and scrollbars
 * !important may be added to force override, but not necessary
 * #content is not necessary to hide scroll bars
 */
#TabsToolbar {
  visibility: collapse;
}
#navigator-toolbox {
  visibility: collapse;
}
EOF
)

if [ -z "${profile}" ]; then
	# create a fresh user profile in /tmp/ffnoux-??????
	profile="$(mktemp -d /tmp/ffnoux-XXXXXX)"

	# start ff in headless mode to create a fresh user profile
	firefox \
		--headless \
		--new-instance \
		--first-startup \
		--profile "${profile}" \
		/dev/null \
		&>/dev/null &

	# on my machine a have to wait a bit; you might try it with wait=0
	sleep "${wait}"

	# kill ff headless
	kill %%

	# ff settings to enable chrome user css mode; what ever the f**k this name come from, eh?
	echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >>"${profile}/prefs.js"

	# write chrome uesr css file
	mkdir "${profile}/chrome"
	echo "${css}" >"${profile}/chrome/userChrome.css"
fi

firefox --new-instance --profile "${profile}" "${@}" &>/dev/null &

exit 0
