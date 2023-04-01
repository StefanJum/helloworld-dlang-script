#!/bin/bash

top=workdir
apps="$top"/apps
libs="$top"/libs
uk="$top"/unikraft

app="$apps"/app-helloworld-dlang-betterc

setup_app()
{
	if ! test -d "$uk"; then
		git clone https://github.com/unikraft-upb/unikraft "$uk"
	fi

	pushd "$uk" > /dev/null
	git checkout add-dlang-support-pull
	popd > /dev/null

	if ! test -d "$app"; then
		git clone https://github.com/unikraft-upb/app-helloworld-dlang-betterc "$app"
	fi
}

build_app()
{
	pushd "$app" > /dev/null

	make fetch
	make prepare
	D_COMPILER=gdc make -j $(ncpus)

	popd > /dev/null
}

run_app()
{
	pushd "$app" > /dev/null

	qemu-system-x86_64 \
		-machine pc,accel=kvm -cpu host -nographic \
		-enable-kvm -m 64 -kernel build/app-helloworld-dlang_kvm-x86_64

	popd > /dev/null
}

cmd="$1"

case "$cmd" in
	"setup")
		setup_app
			;;
	"build")
		setup_app
		build_app
		;;
	"run")
		setup_app
		build_app
		run_app
		;;
	*)
		echo "Usage: $0 setup|build|run"
		;;
esac

