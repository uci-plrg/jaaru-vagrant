#!/bin/bash
apt-get update
apt-get -y install cmake g++ clang pkg-config autoconf

su -c /vagrant/data/setup.sh vagrant

