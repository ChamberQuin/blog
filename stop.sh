#!/bin/bash
source $(pwd)/.env

pid=$(ps aux | grep "SimpleHTTPServer $PORT" | grep -v grep | awk '{print $2}')
echo "kill process $pid"
kill -9 $pid
