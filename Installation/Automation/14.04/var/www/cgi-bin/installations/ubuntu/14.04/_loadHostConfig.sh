#!/bin/bash
#--------------------------------------------------------------------------------
# [Auther] 
# Masayuki Onishi 10 JUL 2016 ver 1.0
#--------------------------------------------------------------------------------
# [Function]
# Load the host configuration of the host being installed.
#
# ks.cfg sets the name of the host configuration file to ${ADDRESS} of the configuration.
# When the host under installation accesses CGI/Servlet,the web server sets REMOTE_ADDR
# as the environment variable to the IP address of the host.Using the REMOTE_ADDR, 
# loads the host configuration information.
#--------------------------------------------------------------------------------
echo "#The REMOTE_ADDR is ${REMOTE_ADDR}"
if [ ! -f ./done/${REMOTE_ADDR} ]; then
    echo "The host configuration file is not available. Abort ..."
    exit -1
else
    source ./done/${REMOTE_ADDR}
fi
