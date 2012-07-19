#!/bin/bash
cmd="sudo ipa-server-install --uninstall -U"
echo "uninstall ipa server in unattented mode"
echo "command to execute:[$cmd]"
$cmd
