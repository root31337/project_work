#!/bin/bash
apt-get update
sleep 10
apt-get install mongodb -y
sleep 10
systemctl start mongodb
sleep 10
systemctl enable mongodb
sleep 10