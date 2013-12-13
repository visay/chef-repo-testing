#!/bin/sh
# Exit with status 0 if sidekiq reports e.g. '25 of 25 busy'
ps ax | grep sidekiq | grep '\([0-9]\+\) of \1 busy' 1>&2
