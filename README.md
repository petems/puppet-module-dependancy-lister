# puppet-module-dependancy-lister

Script created to output depdencies for modules taken from the Forge.

It notifies on not found and/or decommissioned modules.

Limitations:
- It only resolves Forge versions, cannot read git modules
- Lines not matching a module might end up out of order

Usage: forge_resolve_version.rb -i /path/to/original/Puppetfile

```
[root@agent1 ~]# ./puppet-module-dependancy-lister.rb -i Puppetfile
Module saz-ssh has Dependancy: puppetlabs/stdlib >= 4.6.0 < 5.0.0
Module saz-ssh has Dependancy: puppetlabs/concat >= 1.2.5 < 3.0.0
Module puppetlabs-apache has Dependancy: puppetlabs/stdlib >= 4.13.1 < 5.0.0
Module puppetlabs-apache has Dependancy: puppetlabs/concat >= 2.2.1 < 5.0.0
Module puppetlabs-mysql has Dependancy: puppetlabs/stdlib >= 3.2.0 < 5.0.0
Module puppetlabs-mysql has Dependancy: puppet/staging >= 1.0.1 < 3.0.0
 Warning: blah-bleh was not found
Module wdijkerman-zabbix has Dependancy: puppetlabs/postgresql >= 4.0.0
Module wdijkerman-zabbix has Dependancy: puppetlabs/stdlib >= 4.1.0
Module wdijkerman-zabbix has Dependancy: puppetlabs/mysql >= 2.0.0
Module wdijkerman-zabbix has Dependancy: puppetlabs/apache >= 1.0.0
Module wdijkerman-zabbix has Dependancy: puppetlabs/firewall >= 1.0.0
Module wdijkerman-zabbix has Dependancy: puppetlabs/ruby >= 0.4.0
Module wdijkerman-zabbix has Dependancy: puppetlabs/pe_gem >= 0.1.0
Module wdijkerman-zabbix has Dependancy: puppetlabs/apt >= 2.0.0
 Warning: wdijkerman-zabbix is deprecated
```
