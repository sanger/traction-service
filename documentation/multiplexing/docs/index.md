# Multiplexing process overview

## Introduction
Traction represents the multiplexing process through the creation and use of pools. A pool is a collection of libraries (tagged samples) that are combined together for sequencing. Each library/sample in the pool is tagged with a unique tag from a given tag set. The pool itself has some metadata about what it contains namely: total volume, concentration and insert size. These pools are used in sequencing runs as single entities whilst representing the individual libraries within the pool. Once a sequencing run has been setup a sample sheet may be generated where the pool's contents are then represented in a single flowcell/well containing all the pool's samples and library data.

A visual representation of the multiplexing process is shown below:

![process](img/multiplexing-process-map.png)

## Alternative multiplexing strategies
Traction also supports multiplexing at the sequencing run level where multiple pools or libraries are combined together in a single flowcell/well in a run. This is generally less common as it is more complex, requiring consistent tagging across multiple pools/libraries in order to work. However, it is supported in Traction and can be used if required.
