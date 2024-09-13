# Multiplexing process overview

## Introduction

Traction represents the multiplexing process through the creation and use of pools. A pool is a collection of libraries (tagged samples) that are combined together for sequencing. Each library/sample in the pool is tagged with a unique tag from a given tag set. The pool itself has some metadata about what it contains namely: template prep kit box barcode, total volume, concentration and insert size. Pools are used in sequencing runs as single entities whilst representing the individual libraries within the pool. Once a sequencing run has been setup a sample sheet may be generated where the pool's contents are then represented in a single flowcell/well containing all the pool's samples and library data.

A visual representation of the multiplexing process is shown below:

![process](img/multiplexing-process-map.png)

## Basic process

The basic process of multiplexing in Traction is as follows:

1. Samples are imported into Traction and requests are created for them.
    - Typically imported via plates or tubes from Sequencescape.
2. Libraries are created from the requests.
    - Libraries are assigned metadata including volume, concentration, insert size and library kit.
    - A tag may be assigned to the libraries at this stage.
3. Pools are created from the libraries.
    - Users specify which libraries they would like to use in a pool.
    - Requests can also be added to the pool directly from the plates/tubes they were imported on.
    - A single tag set is used and its tags issued to all libraries in the pool. If there is more than 1 library in the pool. Each library in the pool must be tagged with a unique tag from the tag set.
    - Pool metadata includes template prep kit box barcode, total volume, concentration and insert size.
4. Pools are used in sequencing runs.
    - Pools are added to wells on plates for sequencing.
5. A sample sheet is generated.
    - The sample sheet contains the pool's contents and metadata.
    - The sample sheet is used to setup the sequencing run on the sequencing machines.

## Alternative multiplexing strategies

Multiplexing is typically done before run setup, during the pooling process, instead of during run setup by using multiple libraries in each well, because it allows for more flexibility in the lab and a better user experience. Doing it upfront in the pooling process means we can be sure there are no tag clashes, that the data is correct and it reduces the risk of errors during run setup.

However, Traction also supports pooling at the sequencing run level where multiple pools or libraries are combined together in a single flowcell/well in a run. This is generally less common as it is more complex, requiring consistent tagging across multiple pools/libraries in order to work. But it is supported in Traction and can be used if required.
