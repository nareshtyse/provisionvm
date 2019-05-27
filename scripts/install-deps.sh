#!/bin/bash

myself=$(realpath "$0")

function say {
    [ -n "$TERM" ] && echo "$(tput setaf 2)$1$(tput sgr0)" || echo "$1"
}

function fail {
    [ -n "$TERM" ] && echo "$(tput setaf 1)$2$(tput sgr0)" >&2 || echo "$2"
    exit $1
}

function get_item_attr {
    yq -r ".[$2-1].$3//\"$4\"" < "$1"
}

[ -z "${VIRTUAL_ENV}" ] && fail 1 "Virtual environment not found"
[ -z "${ANSIBLE_CONFIG}" ] && fail 2 "ANSIBLE_CONFIG not set"
[ $(id -u) == 0 ] && fail 3 "Refusing to run as root"

[ $# -lt 1 ] && base_dir="$PWD" || base_dir=$(realpath "$1")

repo_name=$(basename "${base_dir}")
extra_modules_yaml="${base_dir}/extra_modules.yml"
requirements_yaml="${base_dir}/requirements.yml"
ansible_modules_dir="${VIRTUAL_ENV}/ansible/modules"
ansible_roles_dir=$(crudini --get "${ANSIBLE_CONFIG}" defaults roles_path)

if [ -e "${base_dir}/requirements.txt" ] ; then
    say "[${repo_name}] Installing python modules..."
    pip install -r "${base_dir}/requirements.txt"
fi

if [ -e "${extra_modules_yaml}" ] ; then
    say "[${repo_name}] Installing python modules for dependencies..."
    pip install $(yq -r ".[].python_deps[]" < "${extra_modules_yaml}")
fi

if [ -e "${base_dir}/requirements.yml" ] ; then
    say "[${repo_name}] Installing roles..."
    ansible-galaxy install -fr "${base_dir}/requirements.yml"
fi

mkdir -p "${ansible_modules_dir}"

start_dir="$PWD"
cd "${ansible_modules_dir}"
if [ -e "${extra_modules_yaml}" ] ; then
    for i in $(seq $(yq ".|length" < "${extra_modules_yaml}")) ; do
        src=$(get_item_attr "${extra_modules_yaml}" $i src)
        version=$(get_item_attr "${extra_modules_yaml}" $i version master)
        al=$(get_item_attr "${extra_modules_yaml}" $i library)
        amu=$(get_item_attr "${extra_modules_yaml}" $i module_utils)
        name=$(basename "${src}" .git)
        say "[${repo_name}] Installing ansible module ${name} ..."
        if [ -d "${ansible_modules_dir}/${name}" ] ; then
            cd "${ansible_modules_dir}/${name}"
            git pull
            git -c advice.detachedHead=false checkout "${version}"
            cd "${ansible_modules_dir}"
        else
            git -c advice.detachedHead=false clone -b "${version}" "${src}"
        fi
        module_dir="${ansible_modules_dir}/${name}/${al}"
        if [ -n "${amu}" ] ; then
            module_utils_dir="${ansible_modules_dir}/${name}/${amu}"
        else
            module_utils_dir=""
        fi
        add-ansible-module.py "${module_dir}" "${module_utils_dir}"
    done
fi
if [ -e "${requirements_yaml}" ] ; then
    for i in $(seq $(yq ".|length" < "${requirements_yaml}")) ; do
        src=$(get_item_attr "${requirements_yaml}" $i src)
        scm=$(get_item_attr "${requirements_yaml}" $i scm git)
        name=$(get_item_attr "${requirements_yaml}" $i name $(basename "${src}" .git))
        [ "${scm}" != "git" ] && continue
        "${myself}" "${ansible_roles_dir}/${name}"
    done
fi
cd "${start_dir}"
