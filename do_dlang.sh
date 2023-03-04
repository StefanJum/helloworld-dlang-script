#!/bin/bash

top=workdir
apps="$top"/apps
libs="$top"/libs
uk="$top"/unikraft

app="$apps"/app-helloworld-dlang

setup_app()
{
	if ! test -d "$uk"; then
		git clone https://github.com/unikraft-upb/unikraft "$uk"
	fi

	pushd "$uk" > /dev/null
	git checkout StefanJum/add-druntime-support
	popd > /dev/null

	if ! test -d "$libs"/lib-musl; then
		git clone https://github.com/unikraft-upb/lib-musl "$libs"/lib-musl
	fi

	pushd "$libs"/lib-musl > /dev/null
	git checkout StefanJum/add-druntime
	popd > /dev/null

	if ! test -d "$libs"/lib-compiler-rt; then
		git clone https://github.com/unikraft/lib-compiler-rt "$libs"/lib-compiler-rt
	fi

	if ! test -d "$libs"/lib-libcxx; then
		git clone https://github.com/unikraft/lib-libcxx "$libs"/lib-libcxx
	fi

	if ! test -d "$libs"/lib-libcxxabi; then
		git clone https://github.com/unikraft/lib-libcxxabi "$libs"/lib-libcxxabi
	fi

	if ! test -d "$libs"/lib-libucontext; then
		git clone https://github.com/unikraft/lib-libucontext "$libs"/lib-libucontext
	fi

	if ! test -d "$libs"/lib-libunwind; then
		git clone https://github.com/unikraft/lib-libunwind "$libs"/lib-libunwind
	fi

	if ! test -d "$libs"/lib-gcc; then
		git clone https://github.com/unikraft/lib-gcc "$libs"/lib-gcc
	fi

	if ! test -d "$libs"/lib-lwip; then
		git clone https://github.com/unikraft/lib-lwip "$libs"/lib-lwip
	fi

	if ! test -d "$libs"/lib-druntime; then
		git clone https://github.com/unikraft-upb/unikraft-libdruntime "$libs"/lib-druntime
	fi

	pushd "$libs"/lib-druntime > /dev/null
	git checkout StefanJum/add-musl-support
	popd > /dev/null

	if ! test -d "$app"; then
		git clone https://github.com/unikraft-upb/app-helloworld-dlang "$app"
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
		-enable-kvm -m 64 -kernel build/helloworld_kvm-x86_64

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
