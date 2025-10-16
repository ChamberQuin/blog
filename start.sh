#!/bin/bash
source $(pwd)/.env

python -m SimpleHTTPServer $PORT &> /dev/null &
python3 -m http.server $PORT &> /dev/null &
