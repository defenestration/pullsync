optimize_menu(){ #run outside of matching_menu() in case version matching is not needed, but optimizations are wanted
	local cmd=(dialog --clear --backtitle "pullsync" --title "Optimization Menu" --separate-output --checklist "Select options for server optimization. Sane options were selected based on your configuration:\n" 0 0 7)
	local options=( 1 "Install mod_http2 for EA4" on
			2 "Install memcached and modules" on
			3 "Install nginx proxy for EA4 (EXPERIMENTAL)" off
			4 "Use FPM for all accounts (converts migrated domains!)" off
			5 "Turn on keepalive, mod_expires, and mod_deflate" off
			6 "Security tweaks" off
			7 "Install mod_pagespeed" off)

	# turn things on front to back
	#nginx on source (6 7 8)
	if [ "$nginxfound" ] && [ "$localea" = "EA4" ]; then
		options[8]=on && cmd[8]=`echo "${cmd[8]}\n(3) Nginx found on source server"`
	fi
	#SSP tweaks (15 16 17)
	if grep -E -q ^SMTP_BLOCK\ ?=\ ?[\'\"]1[\'\"]$ $dir/etc/csf/csf.conf || grep -E -q ^smtpmailgidonly=1$ $dir/var/cpanel/cpanel.config; then
		options[17]=on && cmd[8]=`echo "${cmd[8]}\n(6) SSP tweaks recommended since smtp tweak enabled"`
	fi

	# turn things off back to front
	#basic optimizations (12 13 14)
	if [ ! "$localea" = "EA4" ]; then
		unset options[14] options[13] options[12] && cmd[8]=`echo "${cmd[8]}\n(5) Basic optimization tweaks are not compatible with EA3"`
	fi

	local choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	[ $? != 0 ] && exitcleanup 99
	clear
	echo $choices >> $log
	for choice in $choices; do print_next_element options $choice >> $log; done
	for choice in $choices; do
		case $choice in
			1)	modhttp2=1;;
			2)	memcache=1;;
			3)	nginxproxy=1;;
			4)	fpmdefault=1;;
			5)	basicoptimize=1;;
			6)	ssp_tweaks=1;;
			7)	pagespeed=1;;
			*)	:;;
		esac
	done
}
