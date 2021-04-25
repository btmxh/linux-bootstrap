HOME=/home/gbnam8
PKG=apt
PKG_INSTALL="$PKG install -y"
VIM_CONFIG_DIR=$HOME/.config/nvim
MYVIMRC=$VIM_CONFIG_DIR/init.vim
CCLS_DIR=$HOME/dev/ccls

# Update package lists
$PKG update -y

# Git
$PKG_INSTALL git

# Neovim
$PKG_INSTALL neovim

# clang (used by ccls)
$PKG_INSTALL libclang-dev clang clang-format

# fzf and ag
$PKG_INSTALL fzf silversearcher-ag

# nodejs (used by coc.nvim)
$PKG_INSTALL npm

# cmake (used to build ccls)
$PKG_INSTALL cmake

# python (used to install cpplint)
$PKG_INSTALL python3-pip

# glfw
$PKG_INSTALL libglfw3-dev

# git configs
git config --global user.name "ngoduyanh"
git config --global user.email "ngoduyanh.chip@gmail.com"

mkdir ~/.config
mkdir ~/.config/nvim

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

yes | cp -rf ./vim/* $VIM_CONFIG_DIR

if [[ ! -d "$CCLS_DIR" ]]
then
git clone --recursive --depth=1 https://github.com/MaskRay/ccls.git $CCLS_DIR
fi

cmake -S "$CCLS_DIR" -B "$CCLS_DIR/Release" -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/usr/lib/llvm-10 -DLLVM_INCLUDE_DIR=/usr/lib/llvm-10/include -DLLVM_BUILD_INCLUDE_DIR=/usr/include/llvm-10

cmake --build "$CCLS_DIR/Release" --target install

pip3 install cpplint

# Non programming stuff

# gimp (for image processing) and kdenlive (for video editing)
$PKG_INSTALL gimp kdenlive

# rust (needs confirmation)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

