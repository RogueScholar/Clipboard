#!/bin/sh
. ./resources.sh
export CLIPBOARD_FORCETTY=1
setup_dir copy-text

clipboard copy "Foobar"

item_is_in_cb 0 rawdata.clipboard

pass_test copy-text