#!/bin/bash -xe
set -x
set -e

wait_for_lock() {
    while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done
}

retry_max() {
    MAX_RETRIES="$1"

    shift
    COMMAND="$@"

    RETRY=1
    while [ $RETRY -le $MAX_RETRIES ]; do
        wait_for_lock
        if $COMMAND; then
            return
        fi
        ((RETRY++))
    done
    return 1
}

add-apt-repository ppa:ansible/ansible -y

retry_max 3 apt-get update
retry_max 3 apt-get install -y ansible

cd /home/ubuntu/ansible
ansible-playbook /home/ubuntu/ansible/site.yml
