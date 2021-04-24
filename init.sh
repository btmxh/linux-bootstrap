HOME=/home/gbnam8
PKG=apt
VIM_CONFIG_DIR=$HOME/.config/nvim
MYVIMRC=$VIM_CONFIG_DIR/init.vim
CCLS_DIR=$HOME/dev/ccls

# Update package lists
$PKG update -y

# Git
$PKG install -y git

# Neovim
$PKG install -y neovim

# clang (used by ccls)
$PKG install -y libclang-dev clang clang-format

# fzf and ag
$PKG install -y fzf silversearcher-ag

# nodejs (used by coc.nvim)
$PKG install -y npm

# cmake (used to build ccls)
$PKG install -y cmake

# python (used to install cpplint)
$PKG install -y python3-pip

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

