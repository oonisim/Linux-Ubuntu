
<h1>Objective</h1>
<p>Build the master administration server which runs DNS server, NTP server, Puppet server for the auto installation from a Git repository and local Ubunto repository.</p>
<hr />
<h2>Preparation</h2>
<p>In case to use Git server.</p>
<ol>
<li>
<p>Create hosts &nbsp;entries for puppet server (itself) and Git server if required.</p></li>
<li>
<p>Setup ssh for Git access.</p><ac:structured-macro ac:name="code" ac:schema-version="1" ac:macro-id="3dc78306-e972-4044-8c7e-ddac709a83ae"><ac:plain-text-body><![CDATA[mkdir ~/.ssh && cd ~/.ssh

# copy gitgs.ssh file here and remove group/other r/w permissions.

touch config
# Update the config file as below.
----
Host gitgs.wynyardgroup.com
  IdentityFile ~/.ssh/gitgs.ssh
----]]></ac:plain-text-body></ac:structured-macro></li></ol>
<h2>Script</h2>
<p><span style="color: rgb(51,51,51);font-size: 14.0px;line-height: 1.42857;">See&nbsp;</span><a href="https://git.wynyardgroup.com/monishi/Linux-Ubuntu/blob/master/Installation/Automation/14.04/utilities/master/mastersetup.sh">mastersetup.sh</a><a style="font-size: 14.0px;line-height: 1.42857;"></a><span style="color: rgb(51,51,51);font-size: 14.0px;line-height: 1.42857;"> in the Git repository.</span></p>
<hr />
<h2>DNS</h2>
<p>Thias BIND Puppet Module.&nbsp;<span>WIth&nbsp;</span><a href="https://forge.puppet.com/thias/bind" rel="nofollow">https://forge.puppet.com/thias/bind</a><span>&nbsp;(Version 0.5.2 released Feb 2nd 2016) configured DNS server for Ubuntu.&nbsp;</span></p>
<p>To work with Ubuntu 14.04 where /etc/bind has default configurations, made changes to the template.</p>
<h3>Ubuntu BIND directory</h3><ac:structured-macro ac:name="code" ac:schema-version="1" ac:macro-id="5bfd8dc4-8f3c-442c-8e8a-50837c38bd85"><ac:plain-text-body><![CDATA[/etc/bind
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
└── zones.rfc1918]]></ac:plain-text-body></ac:structured-macro>
<h3>template/named.conf.erb</h3>
<p>&quot;.&quot; Dot Zone configuration</p><ac:structured-macro ac:name="code" ac:schema-version="1" ac:macro-id="70f79acd-23bd-458f-aeca-2e94af0dab03"><ac:plain-text-body><![CDATA[/*--------------------------------------------------------------------------------
Ubuntu 14.04 default BIND has include named.conf.local which handles "." zone.
Hence this causes duplicate definition issue.
<% if @recursion == 'yes' -%>
zone "." IN {
    type hint;
    file "named.ca";
};
--------------------------------------------------------------------------------*/]]></ac:plain-text-body></ac:structured-macro>
<p>named.rfc1912.zones configuraiton</p><ac:structured-macro ac:name="code" ac:schema-version="1" ac:macro-id="f62cd8a8-1f25-4550-aeaf-ff8d0baa5738"><ac:plain-text-body><![CDATA[/*--------------------------------------------------------------------------------
Ubuntu 14.04 does not have named.rfc1912.zones file, hence causing file not found issue.
<% if @recursion == 'yes' -%>
include "/etc/named.rfc1912.zones";
<% end -%>
--------------------------------------------------------------------------------*/]]></ac:plain-text-body></ac:structured-macro>
<p>Query logging configuration.</p><ac:structured-macro ac:name="code" ac:schema-version="1" ac:macro-id="7a162e2b-b978-4a19-a8f8-6cb5a7d2ffd5"><ac:plain-text-body><![CDATA[logging {
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
};]]></ac:plain-text-body></ac:structured-macro>
<h3><span style="color: rgb(0,0,0);">Puppet Manifest</span></h3>
<ul>
<li><a href="https://github.com/oonisim/Linux-Ubuntu/tree/master/Installation/Automation/14.04/etc/puppetlabs/code/environments/production/manifests/site_dns">See Git repository</a>.</li></ul>
<h3>Zone Files</h3>
<p>Maintain the latest DNS zone files in the repository.</p>
<hr />
<h2>NTP</h2>
<p><a href="https://github.com/oonisim/Linux-Ubuntu/tree/master/Installation/Automation/14.04/etc/puppetlabs/code/environments/production/manifests/site_ntp/manifests">See Git repository</a> for manifests and modules.</p>