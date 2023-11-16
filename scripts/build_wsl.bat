pushd %~dp1
wsl bash ./scripts/build.sh %1
popd