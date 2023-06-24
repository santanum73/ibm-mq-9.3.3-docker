#!/bin/bash
# -*- mode: sh -*-
# © Copyright IBM Corporation 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

# Replace the existing configuration file, mqwebuser.xml with the basic registry sample file 
su -lp mqm -c "cp /opt/mqm/web/mq/samp/configuration/basic_registry.xml /var/mqm/web/installations/Installation1/servers/mqweb/mqwebuser.xml" 

# Enable remote connections to the mqweb server to specify all available network interfaces
su -lp mqm -c 'setmqweb properties -k httpHost -v "*"'

# Enable the administrative REST API for MFT
su -lp mqm -c "setmqweb properties -k mqRestMftEnabled -v true"

# Configure which queue manager is the co-ordination queue manager
su -lp mqm -c "setmqweb properties -k mqRestMftCoordinationQmgr -v ${MQ_QMGR_NAME}"

# enable POST calls, configure which queue manager
su -lp mqm -c "setmqweb properties -k mqRestMftCommandQmgr -v ${MQ_QMGR_NAME}"

# Start the mqweb server
su -lp mqm -c "strmqweb"

# Determine the URI for the IBM MQ Console
su -lp mqm -c "dspmqweb status"
