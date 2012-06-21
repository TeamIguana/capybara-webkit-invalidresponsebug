#! /bin/bash

while true; do
    bundle exec ruby bug.rb
    if [ $? -eq 1 ];then
      exit 1
    fi
done