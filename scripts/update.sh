#!/bin/bash

echo 'Apps to update:'
brew outdated
brew cask outdated

echo ' '
echo 'Updating Applications...'
    brew update
    brew upgrade
    brew cask upgrade

echo ' '
echo 'Cleaning caches and directories...'
    brew cleanup -s

echo ' '
echo 'Updating Complete!'