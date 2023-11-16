pushd %~dp1
wsl ./scripts/init_db_wsl.sh %1
popd