#!/bin/bash
SCRIPT_DIR=`dirname $0`
APP_HOME=$SCRIPT_DIR/..
kill -USR2 `cat $APP_HOME/tmp/pids/unicorn.pid`
