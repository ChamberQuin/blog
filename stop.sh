#!/bin/bash
pid=$(ps aux | grep SimpleHTTPServer | grep -v grep | awk '{print $2}')
echo "kill process $pid"
kill -9 $pid
