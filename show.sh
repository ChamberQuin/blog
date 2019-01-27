#!/bin/bash
source $(pwd)/.env

ps aux | grep "SimpleHTTPServer $PORT" | grep -v grep
