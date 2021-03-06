#!/bin/bash
#############################################################################
# A shell script for running acceptance tests from travis via AWS.
#############################################################################

# Setup global variables
#export DEBUG=1
#export EXCON_DEBUG=1
export FOG_RC=./secrets/fog.rc
export GITREPO='https://github.com/locp/cassandra.git'
export REMOTE_USER="ec2-user"

NODE_TOTAL=$( ruby -e "require 'yaml'; t = YAML.load_file('.travis.yml'); print t['matrix']['include'].count" )
NODE_NUMBER=$( echo $TRAVIS_JOB_NUMBER | cut -d. -f2 )
NODE_NUMBER=`expr $NODE_NUMBER - 1`

echo "NODE_NUMBER         : $NODE_NUMBER"
echo "NODE_TOTAL          : $NODE_TOTAL"
echo "TRAVIS_BUILD_ID     : $TRAVIS_BUILD_ID"
echo "TRAVIS_BUILD_NUMBER : $TRAVIS_BUILD_ID"
echo "TRAVIS_JOB_ID       : $TRAVIS_JOB_ID"
echo "TRAVIS_JOB_NUMBER   : $TRAVIS_JOB_NUMBER"
echo "TRAVIS_TEST_RESULT  : $TRAVIS_TEST_RESULT"

#############################################################################
# Check if we are to run this at all.
#############################################################################

echo "$TRAVIS_BRANCH" | grep -Eq '^release/[0-9]{1,4}/v[0-9]'

if [ $? != 0 ]; then
  echo "Not on a release branch, skipping acceptance tests."
  exit 0
fi

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo "This is a pull request, skipping acceptance tests."
  exit 0
fi

if [ "$TRAVIS_TEST_RESULT" != 0 ]; then
  echo "Travis has already detected a failure, skipping acceptance tests."
  exit 0
fi

#############################################################################
# Provision the AWS node.
#############################################################################
tar xvf secrets.tar
instance_info=`ruby scripts/travis_provision.rb`
instance_id=`echo $instance_info | cut -d: -f1`
instance_public_ip_address=`echo $instance_info | cut -d: -f2`

# Strip whitespace
instance_id=`echo $instance_id`
instance_public_ip_address=`echo $instance_public_ip_address`

echo "Instance ID               : $instance_id"
echo "Instance Public IP Address: $instance_public_ip_address"

# Upload Payload
ssh_retries=10
ssh_attempt=1
sleep_period=20

while [ $ssh_attempt -lt $ssh_retries ]; do
  scp -i secrets/travis.pem -B -o "StrictHostKeyChecking no" \
    scripts/travis_payload.sh $REMOTE_USER@${instance_public_ip_address}:/var/tmp

  if [ $? -ne 0 ]; then
    echo "Attempt $ssh_attempt of $ssh_retries failed."
    ssh_attempt=`expr $ssh_attempt + 1`
    echo "Will retry in $sleep_period seconds."
    sleep $sleep_period
  else
    break
  fi
done

# Execute Payload
ssh -i ./secrets/travis.pem -o "StrictHostKeyChecking no" \
  $REMOTE_USER@${instance_public_ip_address} /var/tmp/travis_payload.sh \
  $GITREPO $TRAVIS_BRANCH $NODE_NUMBER $NODE_TOTAL
status=$?

ruby scripts/travis_destroy.rb $instance_id
exit $status
