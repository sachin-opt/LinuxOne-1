#!/bin/bash

echo "=== EX280 - Question 20 Validation Script ==="

project="marathon"
cronjob_name="scaling"

echo -n "Checking cronjob '$cronjob_name' in project '$project'... "
if oc get cronjob $cronjob_name -n $project &> /dev/null; then
  echo "✅ CronJob found"
else
  echo "❌ CronJob not found"
fi

echo "Checking cronjob schedule... "
schedule=$(oc get cronjob $cronjob_name -n $project -o jsonpath='{.spec.schedule}')
if [[ "$schedule" == "5 4 */2 * *" ]]; then
  echo "✅ Schedule correct"
else
  echo "❌ Schedule incorrect: $schedule"
fi

echo "=== Validation Complete ==="
