#!/bin/bash

_test_files=(tests/*_test.sh)
_all_tests_passed=true

for file in "${_test_files[@]}" ; do
  echo "Running $file"
  zsh $file || _all_tests_passed=false
done

if $_all_tests_passed; then
  echo -e "\033[32mAll tests passed successfully!\033[0m"
else
  echo -e "\033[31mSome tests failed.\033[0m"
fi
