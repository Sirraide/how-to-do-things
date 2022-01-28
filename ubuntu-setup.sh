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

working_directory=$(pwd -P)

echo -n -e "\033[33mPlease input the absolute path to your main shell config (e.g. \033[32m/home/username/.bashrc\033[33m) \033[0m"
read -p "" shell_config_path

[ -f "$shell_config_path" ] || die "File \033[33m$shell_config_path\033[31m does not exist or cannot be accessed."

# Install clang
info_same_line 'Press any key to install \033[32mclang\033[33m (^C to abort) '
read -r -n 1 ignored

installed_clang=0

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
	installed_clang=1
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

# Install ninja
info_same_line 'Press any key to install \033[32mninja\033[33m (^C to abort) '
read -r -n 1 ignored
if [[ -e '/bin/ninja' ]]; then
	info "A version of ninja is already installed."
	info "Uninstall it and run this script again to update it."
	info "Installing ninja - Skipped"
else
	info 'Installing ninja...'
	run "apt-install ninja-build"
fi

# Install nasm
info_same_line 'Press any key to install \033[32mnasm\033[33m (^C to abort) '
read -r -n 1 ignored
if [[ -e '/bin/nasm' ]]; then
	info "A version of nasm is already installed."
	info "Uninstall it and run this script again to update it."
	info "Installing nasm - Skipped"
else
	info 'Installing nasm...'
	run "apt-install nasm"
fi

# Install build-essential
info_same_line 'Press any key to install \033[32mbuild-essential\033[33m (^C to abort) '
read -r -n 1 ignored
info 'Installing build-essential...'
run "apt-install build-essential"

# Generate install script
cd "$working_directory"
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

if [ "$installed_clang" = 1 ]; then
	cat >> $install_script <<-EOF

		info 'Setting default c/c++ compiler to clang'
		run "echo 'export CC=clang' >> ~/$shell_config_path"
		run "echo 'export CXX=clang++' >> $shell_config_path"
		run "source $shell_config_path"
	EOF
fi

cat >> $install_script <<-'EOF'

	working_directory=$(pwd -P)

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
	run "source $shell_config_path"
EOF

cat >> $install_script <<-'EOF'
	run 'nvm install node'
	run 'nvm use node'
	run 'nvm alias default node'

	info 'Successfully installed nodejs'
	info 'As a last step, please run \033[32msource ~/.bashrc'
EOF

cat >> $install_script <<-EOF
	info "As a last step, please run \033[32msource $shell_config_path"
EOF


if [[ -f "$install_script" ]]; then
	chmod +rwx "$install_script"
else
	die "Error: Could not generate $install_script!"
fi

info "Do \033[32m./$install_script\033[33m to complete the installation and to install \033[32mnodejs"
