# Opens a Travis-CI fold, iff we’re running on Travis-CI.
#
# @param $1 The name of the fold, should be matched by a call to travis_fold_close() with the same
#            parameter.
# @param $2 The header which should be shown on the first line of the group.
travis_fold_open() {
	travis_fold start "$1" "$2"
}

# Closes a Travis-CI fold, iff we’re running on Travis-CI.
#
# @param $1 The name of the fold, needs to match an already opened fold.
travis_fold_close() {
	travis_fold end "$1" ""
}

# Manipulate a Travis-CI group folding.
#
# @param $1 The type of fold action. Valid options are "start" and "end".
# @param $2 The name of the fold, needs to match an already opened fold.
# @param $3 The header which should be shown on the first line of the group.
travis_fold() {
	if [ "$TRAVIS" == "true" ]; then
		action="$1"
		name="$2"
		heading="$3"
		echo -en "travis_fold:${action}:${name}\r\033[0K${heading}\n"
	fi
}
