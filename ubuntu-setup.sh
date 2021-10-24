#!/usr/bin/env bash

info() {
	echo -e "\033[33m$1\033[0m"
}

info_same_line() {
	echo -e -n "\033[33m$1\033[0m"
}

run() {
	info "# $1"
	eval "$1"
}

die() {
	echo -e "\033[31m$1\033[0m"
	exit 1
}

set -eu

if [[ $EUID -ne 0 ]]; then
	die 'Error: this script must be run as root'
fi

WORKING_DIRECTORY=$(pwd -P)

echo -n -e "\033[33mPlease input the absolute path to your main shell config (e.g. \033[32m/home/username/.bashrc\033[33m) \033[0m"
read -p "" SHELL_CONFIG_PATH

[ -f "$SHELL_CONFIG_PATH" ] || die "File \033[33m$SHELL_CONFIG_PATH\033[31m does not exist or cannot be accessed."

# Install clang

info_same_line 'Press any key to install \033[32mclang\033[33m (^C to abort) '
read -r -n 1 ignored

INSTALLED_CLANG=0

if [[ -e '/bin/clang' ]]; then
	info "A version of clang is already installed."
	info "Uninstall it and run this script again to update it."
	info "Installing clang - Skipped"
else
	info 'Installing clang...'
	info 'Changing directory to /tmp...'
	cd /tmp
	run 'bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"'
	run 'ln -s /bin/clang-13 /bin/clang'
	run 'ln -s /bin/clang /bin/clang++'
	INSTALLED_CLANG=1
fi

# Install cmake

info_same_line 'Press any key to install \033[32mcmake\033[33m (^C to abort) '
read -r -n 1 ignored

if [[ -e '/bin/cmake' ]]; then
	info "A version of cmake is already installed."
	info "Uninstall it and run this script again to update it."
	info "Installing cmake - Skipped"
else
	info 'Installing cmake...'
	info 'Changing directory to /opt...'
	cd /opt

	[[ -d 'cmake' ]] || rm -rf cmake
	mkdir cmake

	cmake_version="cmake-3.21.2-linux-x86_64"
	run "wget https://github.com/Kitware/CMake/releases/download/v3.21.2/$cmake_version.sh"
	run "chmod +x $cmake_version.sh"
	run "./$cmake_version.sh --skip-license --prefix=/opt/cmake/"
	run "ln -s /opt/cmake/bin/cmake /bin/cmake"
fi

# Generate install script
cd "$WORKING_DIRECTORY"
install_script='install.sh'
cat > $install_script <<-'EOF'
	#!/usr/bin/env bash
	# This script was automatically generated. Do not modify!

	set -eu

	info() {
	    echo -e "\033[33m$1\033[0m"
	}

	info_same_line() {
	    echo -e -n "\033[33m$1\033[0m"
	}

	run() {
	    echo -e "\033[33m$ $1\033[0m"
	    eval "$1"
	}

	if [[ $EUID -eq 0 ]]; then
	    echo -e "\033[31mError: do not run this script as root\033[0m"
	    exit 1
	fi
EOF

if [ "$INSTALLED_CLANG" = 1 ]; then
	cat >> $install_script <<-'EOF'

		info 'Setting default c/c++ compiler to clang'
		run "echo 'export CC=clang' >> ~/$"
		run "echo 'export CXX=clang++' >> $SHELL_CONFIG_PATH"
		run "source $SHELL_CONFIG_PATH"
	EOF
fi

cat >> $install_script <<-'EOF'
	WORKING_DIRECTORY=$(pwd -P)

	info_same_line 'Press any key to install or update \033[32mnodejs\033[33m (^C to abort) '
	read -r -n 1 ignored

	info 'Installing nodejs...'
	info 'Changing directory to /tmp'
	cd /tmp

	if [[ -e './install.sh' ]]; then
	    run 'sudo rm -f ./install.sh'
	fi

	run 'wget https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh'
	run 'chmod +x install.sh'
	run './install.sh'
	run 'export NVM_DIR="$HOME/.nvm"'
	run '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
	run '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'
EOF

cat >> $install_script <<-EOF
	run "source $SHELL_CONFIG_PATH"
EOF

cat >> $install_script <<-'EOF'
	run 'nvm install node'
	run 'nvm use node'
	run 'nvm alias default node'

	info 'Successfully installed nodejs'
EOF

cat >> $install_script <<-EOF
	info "As a last step, please run \033[32msource $SHELL_CONFIG_PATH"
EOF


if [[ -f "$install_script" ]]; then
	chmod +rwx "$install_script"
else
	die "Error: Could not generate $install_script!"
fi

info "Do \033[32m./$install_script\033[33m to complete the installation and to install \033[32mnodejs"
