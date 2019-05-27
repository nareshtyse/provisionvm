#!/usr/bin/env python

import os
from ConfigParser import ConfigParser


def add_ansible_module(module_dir, module_utils_dir=None):
    config = ConfigParser()
    config.read(os.environ['ANSIBLE_CONFIG'])
    if config.has_option('defaults', 'library'):
        cur_module_dir = config.get('defaults', 'library').split(':')
    else:
        cur_module_dir = []
    if config.has_option('defaults', 'module_utils'):
        cur_module_utils_dir = config.get('defaults', 'module_utils').split(':')
    else:
        cur_module_utils_dir = []
    changed = False
    if module_dir not in cur_module_dir:
        cur_module_dir.append(module_dir)
        config.set('defaults', 'library', ':'.join(cur_module_dir))
        changed = True
    if module_utils_dir and module_utils_dir not in cur_module_utils_dir:
        cur_module_utils_dir.append(module_utils_dir)
        config.set('defaults', 'module_utils', ':'.join(cur_module_utils_dir))
        changed = True
    if changed:
        with open(os.environ['ANSIBLE_CONFIG'], 'w') as cf:
            config.write(cf)


if __name__ == '__main__':
    import sys

    if len(sys.argv) < 2:
        print("Usage: %s MODULE_DIR [MODULE_UTILS_DIR]")
    else:
        add_ansible_module(*sys.argv[1:3])
