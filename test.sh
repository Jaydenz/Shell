#!/bin/bash

if [[ -f nginx*.tar.gz ]]; then
	echo "Y"
else
	echo "N"
	exit 2
fi
