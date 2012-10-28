Simple Continuous Integration for Git Repositories
==================================================

# Prerequisites

## CI Runner
* git (obviously)
* inotify-tools

## CI Display 
* Ruby
* Sinatra (`gem install sinatra`)

# TODOS
This is a work in progress. The following things should be implemented soon:
* Persistency: The build status is lost on machine reboot, as everything is currently
stored in `tmp`
* Some applications might need a configuration step before the testsuite can be run; there
should be a hook in the test process to configure what has to be done with a newly created
repository.

# Running the Runner
The main script of CIGit is the test runner `runner.sh`. It reads a buffer of revisions
and starts a test for each revision it encounters. To start the runner, execute

    bash runner.sh <path to your git repository>

# Display the test status
To take a look at the build status, you can either view the file `/tmp/.build_log`, or run
the sinatra application `display.rb`. When you use the sinatra application, simply point
your browser to `http://<ip of the machine/localhost>:4567/`. You will see a simple HTML
file displaying the status for each tested revision.

# Configuring GIT to push changes
CIGit runs `make test` for revisions stored in a temporary file in `/tmp`. To test new
revisions, use the script `push_refs.sh`. Revisions which are piped into this script are
written into the buffer file. If you want to run your tests automatically, add a hook to
your git repository.

## Running tests on git push
CIgit was build with the intention of having a remote repository which automatically
tests the application on receiving a new changeset. To do this, add a hook `post-receive`
to your remote repository. This hook will be executed after a `git push` is finished. The
hook itself is very simple:

    #!/bin/bash
    #
    # After receiving a push, put the received revs into a buffer
    #

    read from to branch
    git rev-list "$from".."$to" | tac | ~/src/Bash/cigit/push_refs.sh 

From stdin, it reads the last revision before the push and the new revision. Then it reads
all revisions in that range and outputs them into the buffer for the test runner. The
test runner will then handle running one test after the other.
