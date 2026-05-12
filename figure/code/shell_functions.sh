# shell_functions.sh — helpers for running Stata from the Makefile.
#
# Stata always exits 0, even when a command errors out, so `make` cannot tell a
# failed run from a good one.  stata_with_flag works around that by scanning the
# .log Stata leaves behind for a trailing `r(###);` error line.
#
#   stata_with_flag <do-file> [args...]
#
# Run a do-file in batch mode (-e).  Stata writes <do-file-basename>.log in the
# current directory; if it ends in an error, fail the recipe, otherwise delete
# the log.

stata_with_flag() {
	stata_batch "$@"
	local logfile
	logfile="$(basename "${1%.*}").log"
	if grep -q '^r([0-9]*);$' "$logfile"; then
		echo "STATA ERROR: errors while running ${1}" >&2
		echo "Exit status: $(grep '^r([0-9]*);$' "$logfile" | head -1)" >&2
		exit 1
	fi
	rm -f "$logfile"
}

# Pick whichever Stata flavor is on PATH.  On macOS the executables live in
# /Applications/Stata/ and are not on PATH by default — add it with:
#   export PATH="$PATH:/Applications/Stata"
stata_batch() {
	if command -v stata-mp >/dev/null; then
		echo "Running ${*} via Stata/MP ..."
		stata-mp -e "$@"
	elif command -v stata-se >/dev/null; then
		echo "Running ${*} via Stata/SE ..."
		stata-se -e "$@"
	elif command -v stata >/dev/null; then
		echo "Running ${*} via Stata ..."
		stata -e "$@"
	else
		echo "No Stata executable (stata-mp / stata-se / stata) found in PATH." >&2
		echo "On macOS: export PATH=\"\$PATH:/Applications/Stata\"" >&2
		exit 1
	fi
}
