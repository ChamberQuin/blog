#!/bin/bash
source $(pwd)/.env

python -m SimpleHTTPServer $PORT &> /dev/null &
