#!/bin/bash
result=$(oc get group $1 -o name 2> /dev/null)

if [ -n $result ]
then
      echo $result
fi