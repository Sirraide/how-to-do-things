Git operations (especially those used in shell prompts to query the current branch) can be very slow if you move the repository somewhere else on disk;
to fix this, just run `git status`; that should update the `.git` directory.
