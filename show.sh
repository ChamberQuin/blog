#!/bin/bash
source $(pwd)/.env

ps aux | grep "SimpleHTTPServer $PORT" | grep -v grep
ps aux | grep "http.server $PORT" | grep -v grep
