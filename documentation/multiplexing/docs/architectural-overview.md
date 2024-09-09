# Architectural Overview

As mentioned in the [Multiplexing process overview](index.md), the multiplexing architecture is mainly based around the creation and use of pools. This document will provide an overview of the architecture of the multiplexing system, including the responsibilities of each component and how they interact with each other with a focus on pools.

## Entity Relationship Diagram

In order to understand the architecture of the multiplexing system, it is important to understand the entities involved in the system. The following diagram shows the entities involved in the multiplexing system and their relationships.

!!! note

    While both PacBio and ONT Traction pipelines support multiplexing and pooling, the entities and relationships shown in the diagram are specific to the PacBio Traction pipeline. The main difference between the two is the use of polymorphic aliquots and the ability to use premade libraries in the PacBio pipeline.

<figure markdown="span">
    ![ERD](img/pacbio-pool-erd.png)
    <figcaption>Entities used for Multiplexing/Pooling in PacBio Traction</figcaption>
</figure>

### Understanding the Entities

**TagSet**: Represents a set of tags that are used to tag samples in a pool. This entity contains information about the tag set, such as the name and the pipeline it is used in.

**Tag**: Represents a tag that is used to tag a sample in a pool. A tag belongs to a tag set and can be used in multiple pools. This entity contains information about the tag, such as the oligo/sequence. Tag oligos are unique within a tag set and only one tag set is allowed to be used per pool.

**Tube**: A wrapper entity that represents a physical tube and gives libraries and pools their Traction IDs (barcodes). A tube can have one item, typically a sample, library or pool.

**Pacbio::Request**: Represents an instance of a sample in Traction. This is the entity that is used to link back to the actual sample to retrieve related data like sample name. It also contains extra metadata about the sample, such as the source barcode, the library type and the cost code.

**Pacbio::Library**: Represents a library that is created from a request (sample). A library can only have one request where as a request can belong to many libraries. This entity contains information about the library, such as the volume, concentration, insert size, and the library kit used to create the library.

**Pacbio::Pool**: Represents a pool that is created from one or more libraries or requests (samples). A pool can have many libraries and a library can belong to many pools. This entity contains information about the pool, such as the total volume, concentration, insert size, and the pool's tag set. It relates to pools and requests (samples) via the `aliquot` entity using polymorphism.

**Aliquot**: Represents a polymorphic entity that describes a piece of something that has been used somewhere. The `source` is a polymorphic representation of where is has come from, typically a request or library. The `used_by` is a polymorphic representation of where it has been used, typically a pool or well. An Aliquot can have two types, `primary` and `derived`. A `primary` aliquot is one that represents an entities initial state, such as initial volume, whereas a `derived` aliquot is one that is created from a primary aliquot and will have a volume of how much has been 'used' in that instance.

**Pacbio::Well**: Represents a well that is used on a sequencing plate. A well typically has one pool or library but can can have any number of pools and libraries via aliquot polymorphism. This entity contains information about the well, such as the column and row from the plate it is on. It can belong to just one plate.

**Pacbio::Plate**: Represents a plate that is used in a sequencing run. A plate can have many wells. This entity contains information about the plate, such as the plate number and the plate sequencing kit box barcode.

**Pacbio::Run**: Represents a sequencing run that is setup in Traction. A run can have any number of plates, typically one or two. This entity contains information about the run, such as the run name, the sequencing kit used, the state and the system used.

## Architectural decisions

PacBio pooling used to be the same as ONT pooling in Traction. Pools could only support requests in the UI, and then in traction-service libraries would be created from those requests automatically upon pool creation. This was changed to make pools more flexible and allow libraries to be added directly to pools as it was closer aligned to what the lab were doing in reality. The current approach of using aliquots also gives us a flexible and extensible way to manage pools. In the future we could add other entities to be used in pools such as other pools.
