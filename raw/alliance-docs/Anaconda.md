---
title: "Anaconda - Alliance Doc"
source: "https://docs.alliancecan.ca/wiki/Anaconda/en"
author:
published:
created: 2026-04-15
description:
tags:
  - "clippings"
---
## Anaconda

Anaconda is a Python distribution.

Before using Anaconda

We are aware of the fact that Anaconda is widely used in several domains, such as data science, AI, bioinformatics etc. Anaconda is a useful solution for simplifying the management of Python and scientific libraries on a personal computer. However, on a cluster like those supported by the Alliance, the management of these libraries and dependencies should be done by our staff, in order to ensure compatibility and optimal performance. Moreover, using Anaconda on a cluster may lead to multiple problems. Before using Anaconda, we ask that you contact our [Technical support](https://docs.alliancecan.ca/wiki/Technical_support "Technical support"), so that our experts can investigate alternatives with you. If you choose to use Anaconda regardless, note that our team may not be able to support you if you encounter issues.

Anaconda may cause issues on a cluster for multiple reasons:

- Anaconda very often installs software (compilers, scientific libraries etc.) which already exist on our clusters as modules, with a configuration that is not optimal, and which may cause conflicts.
- It installs binaries which are not optimized for the processor architecture on our clusters. Your jobs may be slower because of it.
- It makes incorrect assumptions about the location of various system libraries. Your jobs may encounter errors when running.
- Anaconda uses the $HOME directory for its installation, where it writes an enormous number of files. A single Anaconda installation can easily absorb almost half of your quota for the number of files in your home directory.
- Anaconda is slower than the installation of packages via Python wheels.
- Anaconda modifies the $HOME/.bashrc file, which can easily cause conflicts.

## What are alternatives?

The first step you should take is to contact our [Technical support](https://docs.alliancecan.ca/wiki/Technical_support "Technical support"), so that our experts investigate with your what is the best alternative for your needs. If you prefer to attempt it yourself, two main options are listed below.

## Transition from Conda to virtualenv

A [virtual environment](https://docs.alliancecan.ca/wiki/Python#Creating_and_using_a_virtual_environment "Python") offers you all the functionality which you need to use Python on our clusters. This should be the first option that you explore. Here is how to convert to the use of virtual environments if you use Anaconda on your personal computer:

1. List the dependencies (requirements) of the application you want to use. To do so, you can:
	1. Run `pip show <package_name>` from your virtual environment (if the package exists on [PyPI](https://pypi.org/))
		2. Or, check if there is a requirements.txt file in the Git repository.
		3. Or, check the variable install\_requires of the file setup.py, which lists the requirements.
2. Find which dependencies are Python modules and which are libraries provided by Anaconda. For example, CUDA and CuDNN are libraries which are available on Anaconda Cloud but which you should not install yourself on our clusters - they are already installed.
3. Remove from the list of dependencies everything which is not a Python module (e.g. cudatoolkit and cudnn).
4. Use a [virtual environment](https://docs.alliancecan.ca/wiki/Python#Creating_and_using_a_virtual_environment "Python") in which you will install your dependencies.

Your software should run - if it doesn't, don't hesitate to [contact us](https://docs.alliancecan.ca/wiki/Technical_support "Technical support").

## Using Apptainer

In some situations, the complexity of the dependencies of a program requires the use of a solution where you can control the entire software environment. In these situations, we recommend the tool [Apptainer](https://docs.alliancecan.ca/wiki/Apptainer#Using_Conda_in_Apptainer "Apptainer"); note that a Docker image can be converted into an Apptainer image. The only disadvantage of Apptainer is its consumption of disk space. If your research group plans on using several images, it would be wise to collect all of them together in a single directory of the group's project space to avoid duplication.

We will preface this tutorial on how to use Conda inside a container with the following **important notes**:

- Even inside a container, Conda should not be your preferred solution. Priority should always be given to using [modules](https://docs.alliancecan.ca/wiki/Modules "Modules") from our [software stack](https://docs.alliancecan.ca/wiki/Available_software "Available software"), and [wheels](https://docs.alliancecan.ca/wiki/Python "Python") from our [Python wheelhouse](https://docs.alliancecan.ca/wiki/Available_Python_wheels "Available Python wheels"). These are optimized for our systems and we are better equipped to provide support if you use them. Please [contact us](https://docs.alliancecan.ca/wiki/Technical_support "Technical support") if you need a module or a Python package that is not currently available on our systems.
- This tutorial will use the [micromamba](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html) package manager instead of Conda. If you choose to use Conda instead, keep in mind that its use is subject to [Anaconda's Terms of Service](https://legal.anaconda.com/policies/en?name=terms-of-service#terms-of-service) and might require a [commercial license](https://www.anaconda.com/pricing/terms-of-service-faqs).
- This tutorial shows how to create a read-only image, i.e., a one-off .sif file containing a Conda environment that has everything you need to run your application. We strongly discourage installing software interactively with Conda inside a container and will not show how to do this here.

Creating an Apptainer image and using Conda to install software inside it is a 3-step process. The first step is to create a .yml file describing the Conda environment we wish to create inside the container. In the example that follows, we create the file environment.yml. This file is where we give our environment a name, then give Conda a list of packages that must be installed and the channels where to look for them. For more information [see here](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#create-env-file-manually).

```
name: base
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  - python
  - pip
  - star
  - bwa
  - multiqc
```

Second, we create an Apptainer [image definition file](https://apptainer.org/docs/user/main/definition_files.html). This file, here called image.def, describes what are the steps Apptainer should take to create our image. These steps are:

1. Pull a Docker image from DockerHub that has the micromamba package manager pre-installed.
2. Create a copy of the Conda environment definition file environment.yml inside the container
3. Call micromamba and have it configure the environment defined in environment.yml.

```
Bootstrap: docker
From: mambaorg/micromamba:latest

%files
    environment.yml /environment.yml

%post
    micromamba install -n base --file environment.yml && \
        micromamba clean --all --yes
```

The last step is to build the Apptainer image using the definition file above:

```
module load apptainer
APPTAINER_BIND=' ' apptainer build image.sif image.def
```

You can test that your image provides `multiqc`, for example, like this:

![](https://docs.alliancecan.ca/mediawiki/images/thumb/3/30/Question.png/40px-Question.png)

```
[name@server ~]$ apptainer run image.sif multiqc --help
/// MultiQC 🎃 v1.25.1
 
 Usage: multiqc [OPTIONS] [ANALYSIS DIRECTORY]
...
```