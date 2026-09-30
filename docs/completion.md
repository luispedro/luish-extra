# Supported completions

The commands that luish-extra completes, or intends to complete, by plugin. Nothing here has shipped yet: this
is the target list. A command is on it because a lab uses it, or because it is among the most downloaded
command-line tools on [Bioconda](https://bioconda.github.io/): the top 2000 packages once R, Perl and Python
packages are set aside, which is down to about 21,000 total downloads, plus the widely used tools further down
that list and the ones that Bioconda barely carries (licensed, vendor or GitHub-only tools). Libraries
(`pysam`, `biopython`, …), R, Perl and Bioconductor packages, and packages that only provide a library are left
out.

Commands that luish's standard `completion` plugin already completes (`uv`, `pixi`, `micromamba`, `pip`, `conda`,
`mamba`, `fd`, `rg`, `jq`, `zstd`, `sqlite3`, `tmux`, `nvim`, `loginctl`, `docker`, `podman`, `rclone`, `rsync`, …) are
not repeated here. Commands that only the `bash-completion` bridge covers are still listed: the plugins here are
preferred, and the bridge is the fallback.

Several Bioconda packages provide commands under other names, so completion is by command name, not package name:
`htslib` (`bgzip`, `tabix`, `htsfile`), `blast` (`blastn` and the rest), `gatk4`, `spades`, `abyss`, `mmseqs2`,
`hhsuite`, `ensembl-vep`, `primer3`, `subread`, `trim-galore`, `kalign2` / `kalign3`, `t-coffee`, `transdecoder`,
`rtg-tools`, `picard-slim`, `mummer4`, `bwameth`, `lumpy-sv`, `kmer-jellyfish`, `snakemake-minimal`.

Every command gets its options and subcommands. Where it makes sense, arguments and option values are completed
by kind: FASTA, FASTQ, BAM and other files by extension, reference names, presets, output formats, and so on.

## `bio`: bioinformatics

### Alignment files, variants and intervals

`samtools`, `bcftools`, `bedtools`, `tabix`, `bgzip`, `htsfile`, `vcftools`, `bamtools`, `sambamba`, `samblaster`,
`mosdepth`, `picard`, `gatk`, `bamutil`, `bam-readcount`, `bamhash`, `cramino`, `deeptools` (`bamCoverage`,
`bamCompare`, `computeMatrix`, `plotHeatmap`, `plotProfile`, …), `bedops`, `vcflib`, `vt`, `snpEff`, `SnpSift`,
`vep`, `plink`, `plink2`, `admixture`, `whatshap`, `freebayes`, `lofreq`, `varscan`, `octopus`, `bcbio-variation`,
`delly`, `manta`, `lumpy`, `smoove`, `sniffles`, `cuteSV`, `svim`, `pindel`, `survivor`, `truvari`, `hap.py`,
`rtg`, `fgbio`, `bwameth.py`, `bismark`, `MethylDackel`, `wiggletools`, `mummer` / `nucmer`, `alfred`, `gridss`,
`varlociraptor`, `vardict`, `strelka`, `somaticseq`, `deepvariant`, `clair3`, `svtyper`, `svtools`, `duphold`,
`samplot`, `annotsv`, `paragraph`, `graphtyper`, `vg`, `expansionhunter`, `trgt`, `hiphase`, `sawfish`, `gangstr`,
`slivar`, `vcfanno`, `peddy`, `somalier`, `verifybamid2`, `vembrane`, `vcf2maf`, `gemini`, `genmod`, `ascat`,
`control-freec`, `sequenza-utils`, `cnvpytor`, `wisecondorx`, `snp-sites`, `snp-dists`, `gofasta`, `ivar`,
`nextalign`, `vadr`, `tn93`, `pyfaidx` (`faidx`), `bx-python` scripts, `gffutils-cli`, `pyfastx`, `crossmap`

**UCSC Kent tools**: `bedGraphToBigWig`, `bedToBigBed`, `bigWigToWig`, `bigWigToBedGraph`, `bigWigInfo`,
`bigBedToBed`, `bigBedInfo`, `wigToBigWig`, `faToTwoBit`, `twoBitToFa`, `twoBitInfo`, `faSize`, `faFrag`,
`faSomeRecords`, `liftOver`, `gtfToGenePred`, `genePredToBed`, `genePredToGtf`, `gff3ToGenePred`, `blat`,
`pslCDnaFilter`, `pslSort`, `bedSort`, `bedClip`, `bedIntersect`, `fetchChromSizes`, `chainNet`, `axtChain`, and
the rest of the `ucsc-*` packages

### Mapping and quantification

`bwa`, `bwa-mem2`, `bowtie`, `bowtie2`, `bowtie2-build`, `minimap2`, `hisat2`, `hisat2-build`, `STAR`, `gmap`,
`lastal`, `lastdb`, `last-train` and the other LAST tools, `kallisto`, `bustools`, `salmon`, `stringtie`,
`htseq-count`, `featureCounts`, `rsem-calculate-expression`, `cufflinks`, `regtools`, `tophat`, `chromap`,
`strobealign`, `ngmlr`, `segemehl`, `graphmap`, `snap-aligner`, `novoalign`, `yara_mapper`, `mash`, `sourmash`,
`fastANI`, `skani`, `sylph`, `STAR-Fusion`, `arriba`, `fusioncatcher`, `qualimap`, `umi_tools`, `preseq`, `rmats`,
`suppa`, `portcullis`, `mikado`, `rnaquast`, `trinotate`, `corset`, `scallop`, `psiclass`, `flair`, `isoquant`,
`oarfish`, `alevin-fry`, `simpleaf`, `kb`, `velocyto`, `kma`, `rseqc` scripts (`bam_stat.py`, …)

### Sequence search

`blastn`, `blastp`, `blastx`, `tblastn`, `tblastx`, `makeblastdb`, `blastdbcmd`, `rpsblast`, `diamond`, `mmseqs`,
`foldseek`, HMMER (`hmmsearch`, `hmmscan`, `hmmbuild`, `hmmpress`, `hmmalign`, `phmmer`, `jackhmmer`), Infernal
(`cmsearch`, `cmscan`, `cmbuild`, `cmalign`), `hhblits`, `hhsearch`, `vsearch`, `swarm`, `cd-hit`, `sortmerna`,
`exonerate`, `lastz`, `fasta36` and the other FASTA programs, `mcl`, `interproscan.sh`, `kofamscan`, `usearch`,
`psiblast`, `deltablast`, `dustmasker`, `segmasker`, `windowmasker`, `makeprofiledb`, `blastdb_aliastool`,
`update_blastdb.pl`, `cas-offinder`

### Read QC, trimming and sequence utilities

`fastp`, `fastqc`, `falco`, `multiqc`, `cutadapt`, `trimmomatic`, `trim_galore`, `AdapterRemoval`, `atropos`,
`flexbar`, `fastx_*` (fastx_toolkit), `bbduk.sh` and the other BBMap tools, `seqkit`, `seqtk`, `csvtk`, `seqfu`,
`seqmagick`, `bioawk`, `filtlong`, `chopper`, `nanoq`, `rasusa`, `NanoPlot`, `NanoFilt`, `NanoStat`, `porechop`,
`fastq_screen` (fastq-screen), `fastq-dl`, `kmc`, `jellyfish`, `meryl`, `khmer`, `pear`, `flash`, `sickle`,
`lighter`, `pigz`, `pixz`, `taxonkit`, `sga`, `kat`, `genomescope2`, `smudgeplot`, `nanocomp`, `pycoqc`, `toulligqc`,
`pomoxis`

### Assembly, annotation and polishing

`spades.py`, `metaspades.py`, `megahit`, `abyss-pe`, `velveth`, `velvetg`, `unicycler`, `shovill`, `skesa`,
`flye`, `canu`, `hifiasm`, `miniasm`, `wtdbg2`, `raven`, `verkko`, `racon`, `medaka`, `pilon`, `polypolish`,
`quast`, `busco`, `merqury`, `prodigal`, `prokka`, `bakta`, `pharokka`, `barrnap`, `tRNAscan-SE`, `aragorn`,
`augustus`, `braker.pl`, `TransDecoder.LongOrfs`, `gffread`, `gffcompare`, `agat_*`, `RepeatMasker`,
`RepeatModeler`, `trf`, `maker`, `Trinity`, `funannotate`, `liftoff`, `ragtag.py`, `masurca`, `soapdenovo2`, `minia`,
`idba`, `velvet`, `gfastats`, `compleasm`, `edta`, `earlgrey`, `ltr_retriever`, `tesorter`, `evidencemodeler`, `pasa`,
`gemoma`, `miniprot`, `spaln`, `glimmerhmm`, `snap`, `codingquarry`, `shasta`, `nextdenovo`, `nextpolish`,
`purge_dups`, `yahs`, `trycycler`, `dragonflye`, `plassembler`, `hybracter`, `metamdbg`, `jcvi`

### Long reads

`f5c`, `slow5tools`, `pod5`, `nanopolish`, `megalodon`, `modkit`, `pbmm2`, `ccs`, `lima`, `isoseq3`, `pbsv`, `longshot`,
`winnowmap`, `savana`, `dorado`, `guppy_basecaller`, `guppy_barcoder`, `smrtlink` tools

### Comparative genomics, pangenomes and population genetics

`orthofinder`, `proteinortho`, `sonicparanoid`, `pantools`, `anchorwave`, `wgd`, `cactus`, `minigraph`, `wfmash`, `pggb`,
`odgi`, `seqwish`, `mashmap`, `syri`, `plotsr`, `stacks` (`ustacks`, `cstacks`, …), `ipyrad`, `ddocent`, `angsd`,
`admixtools`, `smartpca`, `treemix`, `gcta`, `regenie`, `shapeit4`, `beagle`, `king`, `selscan`, `bolt`, `impute2`,
`glimpse`, `rfmix`

### Hi-C and epigenomics

`hicexplorer` (`hicFindTADs`, …), `cooler`, `cooltools`, `pairtools`, `pairix`, `chromosight`, `hictk`, `epic2`,
`genrich`, `chromhmm`, `idr`, `phantompeakqualtools`, `ataqv`, `dnmtools`, `biscuit`, `methylpy`, `moabs`, `bsmap`,
`methylartist`

### Alignment and phylogenetics

`mafft`, `muscle`, `clustalw`, `clustalo`, `t_coffee`, `kalign`, `probcons`, `trimal`, `clipkit`, `FastTree`,
`iqtree` / `iqtree2`, `raxml-ng`, `raxmlHPC`, `phyml`, `mrbayes`, `beast`, `hyphy`, `paml` (`codeml`, …), `gappa`,
`epa-ng`, `pplacer`, `treetime`, `gotree`, `goalign`, `ete3`, `quicktree`, `rapidnj`, `sepp`, `phylip`, `prank`, `pasta`,
`poa`, `famsa`, `pal2nal`, `gblocks`, `macse`, `generax`, `modeltest-ng`, `veryfasttree`, `aster`, `figtree`, `tracer`,
`beast2`, `revbayes`, `bali-phy`, `fastme`, `newick_utils`, `phykit`, `sumtrees.py`, `emboss` (`needle`, `water`, …)

### Metagenomics and microbial genomics

`kraken2`, `bracken`, `krakenuniq`, `centrifuge`, `kaiju`, `metaphlan`, `humann`, `motus`, `checkm`, `checkm2`,
`checkv`, `gunc`, `singlem`, `gtdbtk`, `metabat2`, `concoct`, `maxbin`, `das_tool`, `drep`, `coverm`, `vamb`, `genomad`,
`emapper.py`, `mothur`, `qiime`, `picrust2`, `humann`, `krona`, `abricate`, `amrfinder`, `rgi`, `mlst`, `snippy`,
`roary`, `panaroo`, `ppanggolin`, `gubbins`, `prokka`, `srst2`, `sistr`, `ectyper`, `seqsero2`, `kleborate`,
`ariba`, `staramr`, `mykrobe`, `tb-profiler`, `bactopia`, `anvi-*` (anvio), `phispy`, `antismash`, `metawrap`,
`phyloflash`, `graftm`, `dram`, `vibrant`, `virsorter`, `vcontact2`, `iphop`, `phabox`, `instrain`, `binsanity`,
`comebin`, `metacoag`, `binette`, `kmcp`, `ganon`, `metacache`, `krakentools`, `kraken-biom`, `taxpasta`, `metaeuk`,
`insilicoseq`, `unifrac`, `deblur`, `gneiss`, `emperor`, `lefse`, `maaslin2`, `thapbi-pict`, `harpy`, `resfinder`,
`plasmidfinder`, `mob_suite`, `hamronization`, `defense-finder`, `macsyfinder`, `integron_finder`, `islandpath`,
`bigscape`, `deepbgc`, `gecco`, `kaptive`, `pyani`, `parsnp`, `mashtree`, `poppunk`, `pyseer`, `scoary`, `pirate`,
`chewbbaca`, `ska2`, `mentalist`, `ntm-profiler`, `nullarbor`, `dnaapler`, `pyrodigal`, `phanotate`, `minced`,
`platon`, `plasmidid`

### Data access

`esearch`, `efetch`, `elink`, `esummary`, `xtract` and the other `entrez-direct` tools, `prefetch`,
`fasterq-dump`, `fastq-dump`, `vdb-validate` and the other `sra-tools`, `datasets`, `dataformat`,
`ncbi-genome-download`, `genome_updater`, `gdc-client`, `aria2c`, `dx` (dxpy), `ascp` (aspera-cli), `ena-webin-cli`,
`ena-upload-cli`, `pyega3`, `kingfisher`, `pysradb`, `geofetch`, `ffq`, `parallel-fastq-dump`, `refgenie`, `genomepy`,
`bioconvert`, `pygenometracks`, `igv-reports`, `igvtools`, `gw`, `jbrowse2`, `asciigenome`, `goatools`, `gseapy`,
`biom`

### Proteomics and mass spectrometry

`comet`, `peptide-shaker`, `searchgui`, `openms` (`*Tool` binaries), `maxquant`, `msgf_plus`, `percolator`,
`ThermoRawFileParser`, `msconvert` (proteowizard), `crux`, `sage`, `flashlfq`, `msstitch`, `pyprophet`, `easypqp`,
`ms2rescore`, `sirius`, `metfrag`, `mzmine`

### Structure, immunology and CRISPR

`TMalign`, `USalign`, `openstructure`, `anarci`, `abnumber`, `igblast`, `changeo` scripts, `presto` scripts,
`igdiscover`, `trust4`, `optitype`, `hla-la`, `arcas-hla`, `seq2hla`, `mhcflurry`, `crisprme`, `crispresso2`,
`crispritz`, `coot`, `relion`, `smina`, `rxdock`, `obabel` (openbabel), `mgltools`, `colabfold_batch`,
`run_alphafold.py`, `boltz`, `chai`

### Other

`ngless` (and `.ngl` scripts), `SemiBin2` / `SemiBin`, `macrel`, `argnorm`, `gmsc-mapper`, `nextclade`, `pangolin`, `augur`, `auspice`, `usher`, `freyja`, `artic`, `primer3_core`, `RNAfold` and the other
ViennaRNA tools, `meme`, `fimo` and the other MEME suite tools, `homer`, `macs2` / `macs3`, `sicer`, `mageck`,
`cnvkit.py`, `circos`, `igv`, `jbrowse`, `bandage`, `weblogo`, `cellranger`-style single-cell tools such as
`cellsnp-lite`, and, from outside Bioconda, `cellranger`, `cellranger-atac`, `spaceranger`, `bcl2fastq`, `bcl-convert`,
`dragen`, `pbrun` (Parabricks), `table_annovar.pl` and the other ANNOVAR scripts, `gmes_petap.pl` (GeneMark),
`signalp6`, `tmhmm`, `netMHCpan`, `ldsc.py`, `PRSice`, `saige`, `shapeit5`, `eagle`, `stitch`, `pixy`, `flashpca`,
`cellbender`, `vireo`, `souporcell`

## `science`: general scientific computing

- **Workflows**: `jug` (subcommands, and jugfiles `*.py` as arguments), `snakemake` (rules from the Snakefile as
  targets), `nextflow`, `nf-core`, `nf-test`, `cwltool`, `cromwell`, `toil`, `planemo`
- **Writing**: `quarto`, `latexmk`, `pdflatex`, `xelatex`, `bibtex`, `biber`, `pandoc`
- **Interactive Python and R**: `ipython`, `jupyter`, `Rscript`, `R`
- **Plotting and numerics**: `gnuplot`, `glpk` (`glpsol`), `datamash`, `tsv-utils`
- **Tabular data**: `mlr` (Miller), `xsv` / `qsv`, `duckdb`
- **Chemistry and molecular modelling**: `gromacs` (`gmx`), `autodock-vina`, AmberTools (`tleap`, `cpptraj`, `pmemd`), `namd`, `lmp`
- **General command-line utilities that Bioconda ships**: `parallel`, `aria2c`, `pigz`, `singularity` / `apptainer`,
  `awscli`

## `gui`: desktop programs

- **Browsers and mail**: `firefox` (profiles for `-P`), `chromium`, `google-chrome`, `thunderbird`
- **Documents**: `libreoffice` / `soffice` (`--convert-to` formats), `evince`, `okular`, `zathura`, `xdg-open`
- **Editors**: `code` (installed extensions for `--uninstall-extension`), `meld`, `gedit`, `kate`
- **Media and graphics**: `vlc`, `mpv`, `gimp`, `inkscape`, `krita`, `blender`, `obs`, `audacity`, `eog`
- **Bioinformatics viewers**: `cytoscape`, `jalview`, `artemis`, `tablet`, `bandage_ng`, `proksee`, `pymol`, `chimerax`, `vmd`
- **Desktop tools**: `xrandr`, `gsettings`, `dconf`, `notify-send`, `wmctrl`, `xdotool`, `swaymsg`, `hyprctl`

## `dev`: development and deployment

- **Environments and packaging**: `poetry` (the groups, extras, dependencies and sources of `pyproject.toml`, the
  packages of `poetry.lock`), `twine` (the repositories of `~/.pypirc`)
- **Python tooling**: `pytest` (test files and the tests in them, `FILE::CLASS::TEST`; markers; the options of
  pytest-xdist and pytest-cov), `ruff` (rule codes and linter prefixes), `mypy` (error codes)
- **Command-line utilities**: `fzf`, `bat` (`batcat` on Debian; its languages and themes)
- **Version control**: `svn`
- **Web deployment**: `netlify`
- **Android**: `adb`

## `system`: system administration

- **Backups**: `borg`
- **Filesystems**: `fusermount` / `fusermount3` (the FUSE mount points, for `-u`)

## Possible later plugins

- `hpc`: `sbatch`, `squeue`, `scancel`, `sacct`, `srun`, `sinfo`, `qsub`, `bsub`, `module`, `s5cmd`, `globus`
- `cloud`: `aws`, `gcloud`, `az`
- `media`: `ffmpeg`, `magick`, `convert` (ImageMagick's older name), `yt-dlp`
