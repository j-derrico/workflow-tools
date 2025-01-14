#! /bin/bash

# path to docs directory relative to top level of repository
# $GITHUB_WORKSPACE is set if the actions/checkout@v2 action is run first

DOCS_DIR=${GITHUB_WORKSPACE}/docs

# run Make to build the documentation and return to previous directory
cd ${DOCS_DIR}
make clean html
status=$?
cd -

# copy HTML output into directory to create an artifact
mkdir -p artifact/documentation
cp -r ${DOCS_DIR}/_build/html/* artifact/documentation

# check if the warnings.log file is empty
# Copy it into the artifact and documeentation directories
# so it will be available in the artifacts
warning_file=${DOCS_DIR}/_build/warnings.log
if [[ $status != 0 || -s $warning_file ]]; then
  if [ $status != 0 ]; then
    echo "ERROR: 'make clean html' failed with status $status."
  fi
  cp -r ${DOCS_DIR}/_build/warnings.log artifact/doc_warnings.log
  cp artifact/doc_warnings.log artifact/documentation
  echo ERROR: Warnings/Errors found in documentation
  echo Summary:
  grep WARNING ${DOCS_DIR}/_build/warnings.log
  grep ERROR ${DOCS_DIR}/_build/warnings.log
  grep CRITICAL ${DOCS_DIR}/_build/warnings.log
  echo Review this log file or download documentation_warnings.log artifact
  exit 1
fi

echo INFO: Documentation was built successfully.

