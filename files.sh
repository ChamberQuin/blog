#!/bin/bash
tree | grep -vE '\.jpg|\.png|\.sh|\.js|\.css'
