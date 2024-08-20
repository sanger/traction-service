# Supporting Volume Tracking through Schema Registry

Since the process of volume tracking involves a messaging architecture, there are producers and consumers serializing/deserializing messages published and received. To do so, the publishers and consumers need to agree on a certain set of schemas that provide the ability to facilitate this message serialization and deserialization. For example, if a consumer expects an attribute $a_{i}$ from the publisher, and the publisher fails to publish it along with the message, the volume tracking process would err as the message would likely be dead-lettered because the consumer is not able to process the message. Therefore, we have used RedPanda Schema Registry to host the schemas which gives the ability for producers and consumers to use the compatible schemas to publish and consume.

???+ tip

    Schemas evolve. The set of attributes (and the nature of those attributes) the application starts with might get updated as the application matures. Therefore, to support schema evolution, schema registries facilitate schema versioning. As long as the producers and consumers agree on the versions that they use, the messaging process succeed. However, if either the producer and consumer change the schema version they use, the system can run into a compatibility conflict and introduce friction throughout the messaging process. 

    RedPanda Schema Registry has [different compatibility modes](https://docs.redpanda.com/23.2/manage/schema-registry/#configure-schema-compatibility) to choose from when a new subject (schema) is created. The default is `BACKWARD`, where the consumers can consume messages produced by using the schema version (i.e., $v_{k}$) that the consumer agrees with, or the version before that (i.e., $v_{k-1}$) and only that. There are other types of compatibility modes that provide more flexibility such as `FULL` and `FULL_TRANSITIVE` but we have chosen to go for the default compatibility mode, which is `BACKWARD`. How RedPanda facilitates these compatibility modes is by restricting what you _can_ change when the schema evolves. A good explanation on these restrictions is described [here](https://docs.confluent.io/platform/current/schema-registry/fundamentals/schema-evolution.html#summary).

## Avro

To facilitate serialization and deserialization processes using schemas, we used [Avro as our specification](https://avro.apache.org/docs/1.11.1/). It was initially developed by Apache to manage efficient and compact storage of big data. However, our use-case for Avro relies on its ability to lay out a schema for our messages, serialize them (following validation) and validate them upon deserialization. The internals of Avro on how these validations occur are not discussed here. However, a simple guide is given on the process and the tools we used for serialization and deserialization.

It is noteworthy to mention that the publishers and consumers that the volume tracking process involves were written using different technologies. Therefore, here are some points that require highlighting as both the producers and consumers use schemas as a common concept.



### Producers

Producers for volume tracking were written in Ruby (Ruby on Rails as the web framework). The library (i.e., Ruby Gem) we have used to serialize the messages using the schemas is [`avro`](https://rubygems.org/gems/avro/versions/1.8.1?locale=en). We use `avro` library's `Avro::IO::BinaryEncoder` to encode the data into binary format using the schema and send the binary data along the AMQP channel established with the message broker.

### Consumers

Consumers for volume tracking were written in Python. The library we have used to deserialize messages using the schemas is [`fastavro`](https://github.com/fastavro/fastavro). We use `fastavro` library's `schemaless_reader` to decode the data into a Python type and map it in a way that we could access the data inside messages.

## The general process of message serialization and deserialization

The following figure aims to give a bird's-eye perspective on message serialization and deserialization. 

### Publisher

``` mermaid
flowchart LR
  A[Producer] --> B[Fetch schema];
  B --> C[Encode the message];
  C --> F{Validation?};
  F --> |Failure| G[Log Error];
  F --> |Success| D[Push it to queue]
  D --> |consume| E[Consumer];
```

### Consumer

``` mermaid
graph LR
  A[Consumer] --> B[Fetch schema];
  B --> C[Decode the message];
  C --> F{Validation?};
  F --> |Success| E[Push it to warehouse];
  F --> |Failure| D[Dead Letter];
```

## Schema

The hosted schema can be accessed through a [REST API](https://docs.redpanda.com/api/pandaproxy-schema-registry/#overview) given by RedPanda. It can also be accessed by the RedPanda Console. The subject of the schema hosted for volume tracking is `create-aliquot-in-mlwh`. Given below is the `version=1` of the schema.

```json linenums="1"
{
    "type": "record",
    "name": "CreateAliquotInMLWH",
    "namespace": "uk.ac.sanger.psd",
    "doc": "Create an Aliquot in MLWH coming from Traction.",
    "fields": [
        {
            "name": "messageUuid",
            "type": {
                "type": "string",
                "logicalType": "uuid"
            },
            "doc": "Unique message ID."
        },
        {
            "name": "messageCreateDateUtc",
            "type": {
                "type": "long",
                "logicalType": "timestamp-millis"
            },
            "doc": "Date (UTC) that the message was created."
        },
        {
            "name": "limsId",
            "type": "string",
            "doc": "The LIMS system that the aliquot was created in"
        },
        {
            "name": "aliquotUuid",
            "type": {
                "type": "string",
                "logicalType": "uuid"
            },
            "doc": "The UUID of the aliquot in the LIMS system"
        },
        {
            "name": "aliquotType",
            "type": {
                "type": "enum",
                "name": "allowedAliquotType",
                "symbols": [
                    "primary",
                    "derived"
                ]
            },
            "doc": "The type of the aliquot"
        },
        {
            "name": "sourceType",
            "type": {
                "type": "enum",
                "name": "allowedSourceType",
                "symbols": [
                    "well",
                    "sample",
                    "library",
                    "pool"
                ]
            },
            "doc": "The type of the source of the aliquot"
        },
        {
            "name": "sourceBarcode",
            "type": "string",
            "doc": "The barcode of the source of the aliquot"
        },
        {
            "name": "sampleName",
            "type": "string",
            "doc": "The name of the sample that the aliquot was created from"
        },
        {
            "name": "usedByType",
            "type": {
                "type": "enum",
                "name": "allowedUsedByType",
                "symbols": [
                    "library",
                    "pool",
                    "run",
                    "none"
                ]
            },
            "doc": "The type of the entity that the aliquot is used by",
            "default": "none"
        },
        {
            "name": "usedByBarcode",
            "type": "string",
            "doc": "The barcode of the entity that the aliquot is used by"
        },
        {
            "name": "volume",
            "type": "float",
            "doc": "The volume of the aliquot (uL)"
        },
        {
            "name": "concentration",
            "type": [
                "null",
                "float"
            ],
            "doc": "The concentration of the aliquot (ng/ul)",
            "default": null
        },
        {
            "name": "insertSize",
            "type": [
                "null",
                "int"
            ],
            "doc": "The insert size for the aliquot",
            "default": null
        },
        {
            "name": "recordedAt",
            "type": {
                "type": "long",
                "logicalType": "timestamp-millis"
            },
            "doc": "The date and time that the aliquot was recorded"
        }
    ]
}
```

Note that each attribute has its own type, and only some of them can accept `null` values. Also, it is noteworthy to mention attributes such as `sourceType`, which lays out the type of the aliquot source, can only be one of a predefined set of values defined in the schema itself (i.e., an enum with possible values `well`, `sample`, `library`, `pool`). Enforcing optionality and type of such attributes allows the messaging process to be more robust since it would fail at the earliest if the publisher tries to publish a message that does not conform to the schema (i.e., it fails _early_ than _late_).