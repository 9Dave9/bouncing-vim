#!/usr/bin/env bash

get_github_basename () {
  echo "$1" | sed -E 's|.+\/(.+)$|\1|g'
}

utc_timestamp () {
  date -u -d "today" +"%Y%m%dT%H%M%SZ"
}

preserve_existing_vim_rcfile () {
  # Safe to re-run without vimrc.after being replaced by bouncing-vim .vimrc on > 1 iterations
  if [ ! -f ${HOME_DIR}/.vimrc.after ]; then
    # `cp -av` copies the syn-link as apposed to the actual location fo the file
    sudo cp -av ${HOME_DIR}/.vimrc ${HOME_DIR}/.vimrc.after
  fi
}

link_rcfile () {
  local rcfile=$1
  local additional_message=$2

  local rcfile_fullpath="${HOME}/.${rcfile}"
  local rcfile_bkp_path="${HOME}/${rcfile}.$(utc_timestamp).bkp"
  local source_rcfile="${HOME}/.vim/pack/bundle/start/bouncing-vim/rc-files/${rcfile}"

  if [[ $(readlink $rcfile_fullpath) == $source_rcfile ]]; then
    echo "$rcfile is already linking to the provided rcfile"
    return 0
  fi

  echo "
Some of the features require specific configuration, provided by
${source_rcfile}
You can now link to the ${rcfile} provided (your ${rcfile} will be backed up if present).
Do you want to create a symlink? [y/N]:"

  read -r

  if [[ $REPLY =~ ^[Yy] ]]; then
    if [[ -e "${rcfile_fullpath}" && ! -L "${rcfile_fullpath}" ]]; then
      printf "[move] " && mv -v "${rcfile_fullpath}" "${rcfile_bkp_path}"
    else
      echo "No previous ${rcfile} to backup."
    fi

    printf "[symlink] " && ln -sfv "${source_rcfile}" "${rcfile_fullpath}"
  else
    echo "Inspect the provided ${rcfile} for more info."
    echo "${source_rcfile}"
    echo "${additional_message}"
  fi
}

clone_to_bundle_with_home () {
  local github_project=$1
  local home_dir=$2

  local github_basename=$(get_github_basename $github_project)
  local plugin_dir="${home_dir}/.vim/pack/bundle/start/$github_basename"

  if [[ ! -d "${plugin_dir}" ]]; then
    echo "[install] $github_project -> ${plugin_dir}"
    git clone -q "https://github.com/${github_project}.git" "${plugin_dir}"
  else
    echo "[skip] $github_project -> (already installed)"
  fi
}

_get_std_plugin_dir () {
  local github_project=$1
  local github_basename=$(get_github_basename $github_project)
  #vim plugins should be sit in `.vim/pack/bundle/start/` dirrectory
  echo "${HOME}/.vim/pack/bundle/start/${github_basename}"
}

_get_tmp_plugin_dir () {
  local github_project=$1
  local github_basename=$(get_github_basename $github_project)
  echo "${HOME}/.vim/pack/bundle/start/bouncing-vim-tmp-${github_basename}"
}

install_plugin () {
  local github_project=$1
  local std_plugin_dir=$(_get_std_plugin_dir "${github_project}")
  local tmp_plugin_dir=$(_get_tmp_plugin_dir "${github_project}")

  if [[ -d "${tmp_plugin_dir}" ]]; then
    echo "[rename] tmp location: ${tmp_plugin_dir} -> ${std_plugin_dir}"
    mv "${tmp_plugin_dir}" "${std_plugin_dir}"
  elif [[ -d "${std_plugin_dir}" ]]; then
    echo "[skip] $github_project -> already installed"
  else
    echo "[install] $github_project -> ${std_plugin_dir}"
    git clone -q "https://github.com/${github_project}.git" "${std_plugin_dir}"
  fi
}

install_tmp_plugin () {
  local github_project=$1

  local std_plugin_dir=$(_get_std_plugin_dir "${github_project}")
  local tmp_plugin_dir=$(_get_tmp_plugin_dir "${github_project}")

  if [[ -d "${std_plugin_dir}" || -d "${tmp_plugin_dir}" ]]; then
    echo "[skip] $github_project -> already installed"
  else
    echo "[install] $github_project -> ${tmp_plugin_dir}"
    git clone -q "https://github.com/${github_project}.git" "${tmp_plugin_dir}"
  fi
}

ls_tmp_plugins () {
  find "${HOME}/.vim/pack/bundle/start/" -type d -iname 'bouncing-vim-tmp-*'
}

archive_tmp_plugins () {
  local tmp_plugin_name=

  mkdir -p "${HOME}/.vim/_disabled_plugins"

  ls_tmp_plugins | while read tmp_plugin; do
    tmp_plugin_name=$(basename $tmp_plugin)
    mv -v \
      "${tmp_plugin}" \
      "${HOME}/.vim/_disabled_plugins/${tmp_plugin_name}-$(utc_timestamp)"
  done
}

ensure_curl () {
  if [[ ! $(command -v curl) ]]; then
    sudo apt-get update
    sudo apt-get install -y curl
  fi
}

ensure_vim_dir_structure () {
  echo "Ensure a complete ~/.vim dir structure"
  mkdir -v -p ~/.vim/{bundle,pack/bundle/start,autoload,colors,undo,swap,_disabled_plugins}
}
