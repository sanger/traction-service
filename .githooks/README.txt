To use the git hooks in this folder, you need to add the `.githooks` folder to your git config using:
  git config core.hooksPath .githooks

If you wish to turn off the hooks again and restore the default behaviour, you can do that by issuing the command:
  git config --unset core.hooksPath
