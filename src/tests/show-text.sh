#!/bin/sh
. ./resources.sh
export CLIPBOARD_FORCETTY=1

testname="Show user provided text"

start_test "$testname"

clipboard copy "Foobar"

item_is_in_cb 0 rawdata.clipboard

output=$(clipboard show)

content_is_shown "$output" "Foobar"

pass_test "$testname"