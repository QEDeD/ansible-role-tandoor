#!/bin/sh
# SPDX-FileCopyrightText: 2026 QEDeD
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# Controlled CLI responses only; this fixture never invokes Docker.
set -eu

case "$*" in
	'stop -t 7 molecule-tandoor' | 'rm -f molecule-tandoor')
		exit 1
		;;
	'container ls --all --format {{.Names}}')
		case "$TANDOOR_CLEANUP_CASE" in
			absent) printf '%s\n' molecule-tandoor-other other-molecule-tandoor ;;
			present) printf '%s\n' molecule-tandoor ;;
			query-failure) echo 'Container lookup denied' >&2; exit 17 ;;
			*) exit 99 ;;
		esac
		;;
	'container inspect molecule-tandoor')
		# The old implementation mistook this failure for absence when info worked.
		case "$TANDOOR_CLEANUP_CASE" in
			present) exit 0 ;;
			absent) exit 1 ;;
			query-failure) echo 'Container lookup denied' >&2; exit 17 ;;
			*) exit 99 ;;
		esac
		;;
	'info')
		exit 0
		;;
	*)
		echo "Unexpected fixture command: $*" >&2
		exit 99
		;;
esac
