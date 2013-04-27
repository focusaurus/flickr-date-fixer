#!/bin/sh
PROJECT_ROOT=$(dirname "${0}")/..
cd "${PROJECT_ROOT}"
PATH=./node/bin:./node_modules/.bin
grunt coffee
grunt requirejs
coffee app/server.coffee
