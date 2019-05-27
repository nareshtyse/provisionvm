# Ansible-vmware-vm-create

This role is responsible for creating (and deleting) vm's on vmware infrastructure

## Requirements

Requires several dependencies e.g. if using this role directly.

> Installing with pip --user avoids the need for running as root

```bash
pip install ansible==2.7.2 --user
pip install --upgrade pyvmomi --user
```

### pip only install extensions for git, use yum as alternative

sudo yum install -y git

## Role Variables

To use this role, you can import it using the instructions at the bottom of this README

### Mandatory

* ansible_vmware_vm_create_hostname
* ansible_vmware_vm_create_ostype
* ansible_vmware_vm_create_vmsize
* ansible_vmware_vm_create_department

### Optional

See defaults file and vars files.

## Dependencies

* pyvmomi module

## Example Playbook

Including an example of how to use this role (for instance, with variables passed in as parameters) is always nice for users too:

```yaml
---
- hosts: localhost

  vars:
    - ansible_vmware_vm_create_hostname: bartdidit
    # - ansible_vmware_vm_create_state: absent
    - ansible_vmware_vm_create_ostype: linux
    - ansible_vmware_vm_create_vmsize: s
    - ansible_vmware_vm_create_department: cfd
  vars_prompt:
    - name: ansible_vmware_vm_create_vcenter_username
      prompt: "Enter vSphere username"
      private: no
    - name: ansible_vmware_vm_create_vcenter_password
      prompt: "Enter vSphere password"
      private: yes
  gather_facts: no
  connection: local
  roles:
    - ansible-vmware-vm-create

```

## Limitations

At the moment it is not possible to provide variables in a playbook to overwrite the ones that defined in the ~/vars/<t-shirt-sizes>.yml. The [ansible documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable) says that role variables should overwrite the role vars defined in role/vars/<anything>.yml. But this is not the case. Example [here on stackoverflow](https://stackoverflow.com/questions/42883909/passing-variables-to-ansible-roles). If you use [extra vars](http://www.oznetnerd.com/ansible-extra-vars/) on the command line however this works. So at the moment this is the workaround, example: `ansible-playbook vm.yml --extra-vars "ansible_vmware_vm_create_host_num_cpus=4"`
