#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/scripts/helpers.sh"
source "$CURRENT_DIR/scripts/variables.sh"
source "$CURRENT_DIR/scripts/shared.sh"

save_command_interpolation="#($CURRENT_DIR/scripts/resurrect_auto_save.sh)"

supported_tmux_version_ok() {
	$CURRENT_DIR/scripts/check_tmux_version.sh "$SUPPORTED_VERSION"
}

handle_tmux_automatic_start() {
	$CURRENT_DIR/scripts/handle_tmux_automatic_start.sh
}

delay_saving_environment_on_first_plugin_load() {
	if [ -z "$(get_tmux_option "$last_auto_save_option" "")" ]; then
		# last save option not set, this is first time plugin load
		set_last_save_timestamp
	fi
}

add_resurrect_save_interpolation() {
	local status_right_value="$(get_tmux_option "status-right" "")"
	local new_value="${save_command_interpolation}${status_right_value}"
	set_tmux_option "status-right" "$new_value"
}

# on tmux server start, when tmux.conf is sourced there are no sessions and
# `tmux has` reports 1
just_started_tmux_server() {
	tmux has
	[ $? -eq 1 ]
}

start_auto_restore_in_background() {
	$CURRENT_DIR/scripts/resurrect_auto_restore.sh &
}

main() {
	if supported_tmux_version_ok; then
		handle_tmux_automatic_start

		# give user a chance to restore previously saved session
		delay_saving_environment_on_first_plugin_load
		add_resurrect_save_interpolation

		if just_started_tmux_server; then
			start_auto_restore_in_background
		fi
	fi
}
main
