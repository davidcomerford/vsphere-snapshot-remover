# vsphere-snapshot-remover
Yet another PowerCLI script to remove old snapshots

# Requirements
* VMware vCenter Server
* VMware PowerCLI

# Recommended
The principle of least privilege suggests we should only run this as a user with the required privileges.

1. Create new vCenter role *remove-snapshots-only*
1. Create new SSO user *snapshot-cleaner*
1. Assign *snapshot-cleaner* to role *remove-snapshots-only*

# Compatibility
* VMware vCenter Server 6.0
