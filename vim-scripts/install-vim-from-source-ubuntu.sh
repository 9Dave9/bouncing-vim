#!/usr/bin/env bash

# Info:
# - https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source
# - http://stackoverflow.com/questions/11416069/compile-vim-with-clipboard-and-xterm
# - http://www.vimninjas.com/2012/09/21/vim-ruby-python/
#
# For a list of configure options:
# - in src/auto/configure look for ac_user_opts
# - :h +feature-list and :h feature-list

set -e

currdir=$( dirname $0 )

vim_source_dir="${HOME}/Downloads/vim74"
vim_repo_dir="${HOME}/Downloads/vim-hg"

#######################
### Download source ###
#######################

echo
echo "--- [step 1] --- Download source"
echo

echo "Update the apt index"
sudo apt-get update

echo "Ensure ~/Downloads exists"
mkdir -p ~/Downloads/

echo "Remove old vim source"
sudo rm -rf $vim_source_dir

pull_vim_repo () {
  local vim_repo_dir=$1
  local vim_source_dir=$2

  sudo apt-get install mercurial

  echo "Pull vim source from googlecode.com"
  if [[ -d "${vim_repo_dir}" ]]; then
    cd "${vim_repo_dir}"
    hg pull -u
    cd -
  else
    hg clone https://vim.googlecode.com/hg/ "${vim_repo_dir}"
  fi
  cp -R "${vim_repo_dir}" "${vim_source_dir}"
  rm -rf "${vim_source_dir}/.hg"
  rm -f "${vim_source_dir}/.hgignore"
  rm -f "${vim_source_dir}/.hgtags"
}

pull_vim_repo "${vim_repo_dir}" "${vim_source_dir}"

###########################
### Remove Vim packages ###
###########################

echo
echo "--- [step 2] --- Remove Vim packages"
echo

sudo apt-get remove -y \
  vim                  \
  vim-runtime          \
  gvim                 \
  vim-tiny             \
  vim-common           \
  vim-gui-common       \
  vim-gnome            \

############################
### Install dependencies ###
############################

echo
echo "--- [step 3] --- Install dependencies"
echo

# Read the dependencies from an external file, and save them in an array named dependencies
SAVE_IFS=$IFS
IFS=$'\n'
dependencies=($(cat "${currdir}/vim-dependencies-precise.txt"))
IFS=$SAVE_IFS

dependency_list=${dependencies[*]}

sudo apt-get install -y $dependency_list

###############################
### Compile and install vim ###
###############################

echo
echo "--- [step 4] --- Compile and install vim"
echo

configure_options=(
  "--enable-rubyinterp"
  "--with-ruby-command=/usr/bin/ruby"
  "--disable-gui"
  "--with-features=huge"
  "--with-x"
  "--enable-luainterp"
  "--enable-pythoninterp"
  "--enable-perlinterp"
  "--enable-cscope"
  "--prefix=/usr"
)

configure_option_list=${configure_options[*]}

cd $vim_source_dir

echo "run ./configure"
./configure --quiet $configure_option_list

echo "run make"
make --quiet VIMRUNTIMEDIR=/usr/share/vim/vim74

echo "run make install"
sudo make install --quiet

##########################################
### Backup compiled source and cleanup ###
##########################################

echo
echo "--- [step 5] --- Backup compiled source and cleanup"
echo

cd ~/Downloads

archive_filename="vim74-compiled-$(date -u -d "today" +"%Y%m%dT%H%M%SZ").tar.gz"
echo "Archive source to ${archive_filename} for future uninstall."
tar czf "${HOME}/Downloads/${archive_filename}" -C "${HOME}/Downloads" vim74

echo "Remove source dir"
rm -rf $vim_source_dir

###############################
### Set default system vim ####
###############################

echo
echo "--- [step 6] --- Set default system vim"
echo

echo "Add vim to the alternatives"
#                                  <link>          <group>  <path>          <priority>
sudo update-alternatives --install /usr/bin/editor editor   /usr/bin/vim    00
#                              <group>  <path>
sudo update-alternatives --set editor   /usr/bin/vim

########################
### Print final info ###
########################

echo
echo "--- [step 7] --- Summary"
echo

echo "To uninstall, unpack the latest source archive, cd to it, and run:"
echo
echo "    sudo make uninstall"
echo
echo "Run 'vim --version' to get full info about this install"
