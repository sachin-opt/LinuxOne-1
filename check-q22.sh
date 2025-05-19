#!/bin/bash

# Possible locations for must-gather tar file
TAR_LOCATIONS=(
    "/root/ex280-clusterdata.tar.gz"
    "$HOME/ex280-clusterdata.tar.gz"
)

PROJECT="space"
LIVENESS_PORT=8080
INITIAL_DELAY=3
TIMEOUT=10

# Check must-gather tar file existence in known locations
file_found=0
echo -n "Checking must-gather tar file... "
for file in "${TAR_LOCATIONS[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ Found at $file"
        file_found=1
        break
    fi
done

if [ $file_found -eq 0 ]; then
    echo "❌ Missing in all known locations"
fi

# Check current project
echo -n "Checking current project is '$PROJECT'... "
current_project=$(oc project -q)
if [ "$current_project" == "$PROJECT" ]; then
    echo "✅ Yes"
else
    echo "❌ Current project is '$current_project'"
fi

# Check liveness probes on deployments in project
echo "Checking liveness probes on deployments in project '$PROJECT'..."

deployments=$(oc get deploy -n $PROJECT -o jsonpath='{.items[*].metadata.name}')

for deploy in $deployments; do
    echo -n "Deployment '$deploy': "
    probe=$(oc get deploy $deploy -n $PROJECT -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.tcpSocket.port}')
    init_delay=$(oc get deploy $deploy -n $PROJECT -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.initialDelaySeconds}')
    timeout_sec=$(oc get deploy $deploy -n $PROJECT -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.timeoutSeconds}')

    if [ "$probe" == "$LIVENESS_PORT" ] && [ "$init_delay" == "$INITIAL_DELAY" ] && [ "$timeout_sec" == "$TIMEOUT" ]; then
        echo "✅ Liveness probe configured correctly"
    else
        echo "❌ Liveness probe NOT configured as required"
    fi
done
