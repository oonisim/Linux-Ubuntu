# Objective

Build the master administration server which runs DNS server, NTP server, Puppet server for the auto installation from a Git repository and local Ubunto repository.

* * *

## Preparation

In case to use Git server.

1.  Create hosts  entries for puppet server (itself) and Git server if required.

2.  Setup ssh for Git access.

    <ac:structured-macro ac:name="code" ac:schema-version="1" ac:macro-id="3dc78306-e972-4044-8c7e-ddac709a83ae"><ac:plain-text-body></ac:plain-text-body></ac:structured-macro>

## Script

<span style="color: rgb(51,51,51);font-size: 14.0px;line-height: 1.42857;">See </span>[mastersetup.sh](https://git.wynyardgroup.com/monishi/Linux-Ubuntu/blob/master/Installation/Automation/14.04/utilities/master/mastersetup.sh)<a style="font-size: 14.0px;line-height: 1.42857;"></a> <span style="color: rgb(51,51,51);font-size: 14.0px;line-height: 1.42857;">in the Git repository.</span>

* * *

## DNS

Thias BIND Puppet Module. <span>WIth </span>[https://forge.puppet.com/thias/bind](https://forge.puppet.com/thias/bind)<span> (Version 0.5.2 released Feb 2nd 2016) configured DNS server for Ubuntu. </span>

To work with Ubuntu 14.04 where /etc/bind has default configurations, made changes to the template.

### Ubuntu BIND directory

```
/etc/bind
├── bind.keys
├── db.0
├── db.127
├── db.255
├── db.empty
├── db.local
├── db.root
├── named.conf
├── named.conf.default-zones
├── named.conf.local
├── named.conf.options
├── rndc.key
└── zones.rfc1918
```

### template/named.conf.erb

"." Dot Zone configuration
```
/*--------------------------------------------------------------------------------
Ubuntu 14.04 default BIND has include named.conf.local which handles "." zone.
Hence this causes duplicate definition issue.
<% if @recursion == 'yes' -%>
zone "." IN {
    type hint;
    file "named.ca";
};
--------------------------------------------------------------------------------*/
```

named.rfc1912.zones configuraiton

```
/*--------------------------------------------------------------------------------
Ubuntu 14.04 does not have named.rfc1912.zones file, hence causing file not found issue.
<% if @recursion == 'yes' -%>
include "/etc/named.rfc1912.zones";
<% end -%>
--------------------------------------------------------------------------------*/
```

Query logging configuration.

```
logging {
    //--------------------------------------------------------------------------------
    // [AS-32] Added query logging
    //--------------------------------------------------------------------------------
    channel query_log {
        file "/var/log/named/query.log" versions 3 size 5m;
        severity info;
        print-time yes;
        print-severity yes;
        print-category yes;
    };
    category queries {
        query_log;
    };
    //--------------------------------------------------------------------------------
};
```

### <span style="color: rgb(0,0,0);">Puppet Manifest</span>

*   [See Git repository](https://github.com/oonisim/Linux-Ubuntu/tree/master/Installation/Automation/14.04/etc/puppetlabs/code/environments/production/manifests/site_dns).

### Zone Files

Maintain the latest DNS zone files in the repository.

* * *

## NTP

[See Git repository](https://github.com/oonisim/Linux-Ubuntu/tree/master/Installation/Automation/14.04/etc/puppetlabs/code/environments/production/manifests/site_ntp/manifests) for manifests and modules.