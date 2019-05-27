#!/bin/bash

function say {
    [ -n "$TERM" ] && echo "$(tput setaf 2)$1$(tput sgr0)" || echo "$1"
}

function fail {
    [ -n "$TERM" ] && echo "$(tput setaf 1)$2$(tput sgr0)" >&2 || echo "$2"
    exit $1
}

[ -n "${VIRTUAL_ENV}" ] && fail 1 "A virtual environment is already active"
[ $# -lt 1 ] && fail 2 "Please specifiy virtual environment path"
venv=$(realpath "$1")
[ -f "${venv}" ] && fail 3 "${venv} is a file"

if [ ! -d "${venv}" ] ; then
    say "Creating new virtual environment in ${venv}/bin/activate ..."
    virtualenv "${venv}"
fi

say "Activating virtual environment in ${venv}/bin/activate ..."
source "${venv}/bin/activate"

say "Installing dependencies..."
pip install -U pip yq crudini ansible==2.7.4

say "Configuring ansible..."
ansible_dir="${venv}/ansible"
ansible_cfg="${ansible_dir}/ansible.cfg"
ansible_roles_dir="${ansible_dir}/roles"

mkdir -p "${ansible_dir}"
mkdir -p "${ansible_roles_dir}"

crudini --set "${ansible_cfg}" defaults log_path "${ansible_dir}/ansible.log"
crudini --set "${ansible_cfg}" defaults roles_path "${ansible_roles_dir}"

echo "export ANSIBLE_CONFIG=${ansible_cfg}" >>"${venv}/bin/activate"
say "The virtual environment is ready. You can activate it by typing 'source ${venv}/bin/activate'."
