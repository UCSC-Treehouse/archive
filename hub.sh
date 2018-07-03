#!/bin/bash

echo "Synchronizing Jupyter Hub Compendium"
rsync -av /pod/pstore/groups/treehouse/archive/compendium/ \
  ubuntu@hub.treehouse.gi.ucsc.edu:/mnt/archive/compendium

echo "Synchronizing Jupyter Hub Downstream"
rsync -av --exclude '*.bam' --max-size=1g \
  /pod/pstore/groups/treehouse/archive/downstream/ \
  ubuntu@hub.treehouse.gi.ucsc.edu:/mnt/archive/downstream
