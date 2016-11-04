# Ubuntu automated deployment with Kickstart and Preseeding
* Pre-configured ISO image pointing to a web server from which to download kickstart and preseeding files.
* Web server CGI that dynamically generate kickstart and preseeding files from templates for each server deployment.
* Post configurations with Puppet to setup server middleware and applications.
* Ready for air-gapped (no Internet access) environment.

![Overview](https://github.com/oonisim/Linux-Ubuntu/blob/master/Installation/Automation/14.04/AutoInstallationArch.jpg)

## ISO Image
Customize the ISO image to surpress questions, and to download kickstart/preseeding files from the web server.
* Set 'en' in isolinux/lang.
* Set 'timeout 1' in isolinux/isolinux.cfg.

```
    include menu.cfg          # Including menu.cfg content which further includes files.
    default vesamenu.c32
    prompt 0
    timeout 1                 # Timeout configuration. 0: No timeout 1: 1 sec
    ui gfxboot bootlogo
```

* Add kickstart and preseed url in isolinux/txt.cfg.

```
    default install
    label install
      menu label ^Install Ubuntu Server
      kernel /install/vmlinuz
      append  initrd=/install/initrd.gz ks=http://192.168.2.10/cgi-bin/ks.cfg preseed/url=http://192.168.2.10/preseed.txt netcfg/choose_interface=eth0
```   
      
