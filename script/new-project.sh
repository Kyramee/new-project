#!/bin/bash
print_usage() {
  echo ""
  echo "Usage: $(basename "$0") [namespace] [group] [OPTION]..."
  echo "Arguments:"
  echo " [namespace]: Name of the project"
  echo " [group]: Name of the group that own the project"
  echo "Options:"
  echo " -c, --create-namespace: Create a new project with the given namespace"
  echo " -h, --help"
}

POSITIONAL_ARGS=()
CREATE_NAMESPACE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -c|--create-namespace)
      CREATE_NAMESPACE="--create-namespace"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [ $# -ne 2 ]
then
  echo "Error: This script take 2 arguments."
  echo "Use the option --help for the command details."
  exit 1
fi


## Set working path at thr root of the chart
CHART_PATH="$(dirname -- "${BASH_SOURCE[0]}")"       # relative
CHART_PATH="$(cd -- "$CHART_PATH" && pwd)/../.."    # absolutized and normalized
if [[ -z "$CHART_PATH" ]] ; then
  # error; for some reason, the path is not accessible
  # to the script (e.g. permissions re-evaled after suid)
  echo "Can't access path:"
  echo "$CHART_PATH"
  exit 1  # fail
fi


#!/bin/bash
result=$(oc get group $2 -o name 2> /dev/null)

if [ -n $result ]
then
  oc annotate group $2 meta.helm.sh/release-namespace=$1 \
    meta.helm.sh/release-name=$1 --overwrite > /dev/null
  oc label group $2 app.kubernetes.io/managed-by=Helm --overwrite > /dev/null
fi

helm install $1 $CHART_PATH/ -f values.yaml --namespace $2 $CREATE_NAMESPACE