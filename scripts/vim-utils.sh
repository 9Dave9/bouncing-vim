#!/usr/bin/env bash

CURRDIR=$(cd "$(dirname $0)" && pwd -P)

source "${CURRDIR}/../utils.sh"

clone_to_bundle_with_home () {
  local github_project=$1
  local home_dir=$2

  local github_basename=$(get_github_basename $github_project)
  local plugin_dir="${home_dir}/.vim/bundle/$github_basename"

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
  echo "${HOME}/.vim/bundle/${github_basename}"
}

_get_tmp_plugin_dir () {
  local github_project=$1
  local github_basename=$(get_github_basename $github_project)
  echo "${HOME}/.vim/bundle/bouncing-vim-tmp-${github_basename}"
}

install_plugin_with_pathogen () {
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

install_tmp_plugin_with_pathogen () {
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

has_pathogen () {
  if [[ -n $(find ~/.vim -name pathogen.vim) ]]; then
    return 0
  else
    return 1
  fi
}

install_pathogen () {
  echo "Install pathogen to handle your plugins"
  curl -L -o ~/.vim/autoload/pathogen.vim \
    https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
}

ls_tmp_plugins () {
  find "${HOME}/.vim/bundle/" -type d -iname 'bouncing-vim-tmp-*'
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