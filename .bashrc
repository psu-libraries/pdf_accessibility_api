#!/bin/bash
if [ -f /vault/secrets/config ]; then 
    . /vault/secrets/config
fi
alias l='ls -lah'
