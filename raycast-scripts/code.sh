#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open VSCode
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📓
# @raycast.packageName VSCode
# @raycast.argument1 { "type": "dropdown", "placeholder": "repo", "data": [{"title" : "terraform", "value": "terraform"}, {"title" : "terraform-modules", "value": "terraform-modules"}, {"title" : "kubernetes", "value": "kubernetes"}, {"title" : "deploy-metadata", "value": "deploy-metadata"}, {"title" : "deploy-bot", "value": "deploy-bot"}] }

VSCODE_CWD="$PWD"
open -n -b "com.microsoft.VSCode" --args ~/Work/$1

