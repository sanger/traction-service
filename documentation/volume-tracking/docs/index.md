# Volume Tracking

Volume tracking plays a crucial role in the accuracy and reproducibility of DNA long read sequencing, particularly when dealing with primary and derived aliquots. In DNA sequencing, particularly with long reads, the integrity and consistency of the sample volumes are essential for ensuring that the sequencing results are reliable and representative of the original biological material.

Long read sequencing technologies, such as those provided by platforms like PacBio[^1] and Oxford Nanopore[^2], enable the reading of extensive sequences of DNA in a single run, offering significant advantages for complex genome assemblies, structural variation analysis, and epigenetic studies. However, these technologies are highly sensitive to variations in sample preparation, making precise volume management essential from the initial extraction of DNA (primary aliquots) through the subsequent handling and processing (derived aliquots).

Primary aliquots refer to the initial samples obtained directly from the DNA extraction process. These aliquots serve as the foundation for all subsequent sequencing and analysis steps. Derived aliquots, on the other hand, are portions of the primary aliquot that have been further processed, diluted, or otherwise altered to suit specific experimental needs. As each processing step introduces potential variations in volume, precise tracking of these changes is vital to maintain the integrity of the sequencing data.

Effective volume tracking involves monitoring the volume changes at each stage of the workflow, from the initial extraction, through various preparation steps, to the final sequencing run. This ensures that the DNA concentration remains within optimal ranges for sequencing and that the derived aliquots accurately reflect the original sample. Additionally, meticulous volume tracking can help in troubleshooting sequencing issues, ensuring consistency across multiple runs, and facilitating the reproducibility of results.

In this context, understanding and implementing rigorous volume tracking protocols in DNA long read sequencing is essential for researchers aiming to produce high-quality, reliable data that can withstand the scrutiny of rigorous scientific analysis.

[^1]: [PacBio Sequencing 101 Guide](https://www.pacb.com/blog/long-read-sequencing/)
[^2]: [How Oxford NanoPore Works](https://www.nature.com/articles/s41587-021-01108-x)