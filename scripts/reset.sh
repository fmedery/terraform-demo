#!/bin/bash


## very stupid and generic script to start from scratch
## must be used after a destroy to start the demo clean
for folder in demo1 demo2; do
   rm -rf ../$folder/.terraform
   rm ../$folder/*.tfstate*
   rm ../$folder/*.tfstate.backup
done
