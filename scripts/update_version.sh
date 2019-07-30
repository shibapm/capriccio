#!/bin/bash

SEMVER_REGEX="\capriccioVersion =\ \"[0-9]*\.[0-9]*\.[0-9]*\""
sed "s/$SEMVER_REGEX/capriccioVersion = \"$VERSION\"/" Sources/Capriccio/main.swift > tmpMain
mv -f tmpMain Sources/Capriccio/main.swift
