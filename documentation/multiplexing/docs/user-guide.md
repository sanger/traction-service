# User guide

## Overview
This document describes the steps that a user must follow to use the pooling features in Traction.

Pools are available to view and use in both the ONT and PacBio pipelines in Traction. This documentation will focus on the PacBio pipeline, but the steps are similar for the ONT pipeline.
Both pipelines have a dedicated pools tab available at `traction/<pipeline>/pools` where traction is the URL of the Traction UI instance and pipeline is either `ont` or `pacbio`.
Below is an example of the pools index page in the PacBio pipeline:

<figure markdown="span">
    ![Pools index page](img/pacbio-pools-index.png)
    <figcaption>Pools index page</figcaption>
</figure>

Like other index pages in Traction it has the standard features: a search bar with filters, a table of pools with pagination, a print labels button and a link to edit each pool and show more details.
Some notable columns in the pools table include:

- **Ready**: Whether a pool is ready for sequencing. This is determined by whether the pool has any missing data.
- **Pool Barcode**: The barcode of the pool.
- **Source**: A list of sources that make up the pool. These are either library barcodes or request sources like plates and tube barcodes.
- **Actions**: A button to take users to edit that particular pool and a show details button to view more information about the pool.

## Creating a pool

## Editing a pool
