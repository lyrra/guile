#!/usr/bin/env bash

set -e

echo ___________________________________________
echo ___________________________________________
echo ________ Building using timout 3600
echo ___________________________________________
echo ___________________________________________

timeout 3600 make || true

