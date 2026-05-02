---
title: "Getting started - Alliance Doc"
source: "https://docs.alliancecan.ca/wiki/Getting_started"
author:
published:
created: 2026-04-15
description:
tags:
  - "clippings"
---
## What do you want to do?

- If you don't already have an account, see
- If you are an experienced HPC user and are ready to log into a cluster, you probably want to know
	- [what systems are available](#What_systems_are_available?);
		- [what software is available](https://docs.alliancecan.ca/wiki/Available_software "Available software");
		- [how environment modules work](https://docs.alliancecan.ca/wiki/Utiliser_des_modules/en "Utiliser des modules/en");
		- [how to submit jobs](https://docs.alliancecan.ca/wiki/Running_jobs "Running jobs");
		- [how filesystems are organized](https://docs.alliancecan.ca/wiki/Storage_and_file_management "Storage and file management").
- If you are new to HPC, you can
	- [read about how to connect to our HPC systems with SSH](https://docs.alliancecan.ca/wiki/SSH "SSH");
		- [read an introduction to Linux systems](https://docs.alliancecan.ca/wiki/Linux_introduction "Linux introduction");
		- [read about how to transfer files to and from our systems](https://docs.alliancecan.ca/wiki/Transferring_data "Transferring data");
- If you want to know which software and hardware are available for a specific discipline, a series of discipline guides is in preparation. At this time, you can consult the guides on
	- [AI and Machine Learning](https://docs.alliancecan.ca/wiki/AI_and_Machine_Learning "AI and Machine Learning")
		- [Bioinformatics](https://docs.alliancecan.ca/wiki/Bioinformatics "Bioinformatics")
		- [Biomolecular simulation](https://docs.alliancecan.ca/wiki/Biomolecular_simulation "Biomolecular simulation")
		- [Computational chemistry](https://docs.alliancecan.ca/wiki/Computational_chemistry "Computational chemistry")
		- [Computational fluid dynamics](https://docs.alliancecan.ca/wiki/Computational_fluid_dynamics "Computational fluid dynamics") ([CFD](https://docs.alliancecan.ca/wiki/CFD "CFD"))
		- [Geographic information systems](https://docs.alliancecan.ca/wiki/Geographic_information_systems "Geographic information systems") ([GIS](https://docs.alliancecan.ca/wiki/GIS "GIS"))
		- [Visualization](https://docs.alliancecan.ca/wiki/Visualization "Visualization")
- If you have hundreds of gigabytes of data to move across the network, [read about the Globus file transfer service](https://docs.alliancecan.ca/wiki/Globus "Globus").
- Python users can learn how to [install modules in a virtual environment](https://docs.alliancecan.ca/wiki/Python#Creating_and_using_a_virtual_environment "Python").
- R users can learn how to [install packages](https://docs.alliancecan.ca/wiki/R "R").
- If you want to experiment with software that doesn’t run well on our HPC clusters, [read about our cloud resources](https://docs.alliancecan.ca/wiki/Cloud "Cloud").

For any other questions, you might try the *Search* box in the upper right corner of this page, the main page for [our technical documentation](https://docs.alliancecan.ca/wiki/Technical_documentation "Technical documentation") or [contact us by email](https://docs.alliancecan.ca/wiki/Technical_support "Technical support").

## Username and password

Your password to log in to all new national systems is [the same one you use to log into CCDB](https://ccdb.alliancecan.ca/). Your **username** will be displayed at the top of the page once you've logged in.

## What systems are available?

![Screenshot of the "Access Systems" page in CCDB](https://docs.alliancecan.ca/mediawiki/images/thumb/d/d3/Access_Systems.png/500px-Access_Systems.png)

Visit the Access Systems page in CCDB and request access to systems that are suitable for your work.

You can [request access](https://ccdb.alliancecan.ca/me/access_systems) to any or all of our systems: [Arbutus](https://docs.alliancecan.ca/wiki/Cloud_resources "Cloud resources"), [Fir](https://docs.alliancecan.ca/wiki/Fir "Fir"), [Narval](https://docs.alliancecan.ca/wiki/Narval/en "Narval/en"), [Nibi](https://docs.alliancecan.ca/wiki/Nibi "Nibi"), [Rorqual](https://docs.alliancecan.ca/wiki/Rorqual/en "Rorqual/en"), and [Trillium](https://docs.alliancecan.ca/wiki/Trillium "Trillium").

- [Arbutus](https://docs.alliancecan.ca/wiki/Cloud_resources "Cloud resources") is a cloud site, which allows users to launch and customize virtual machines. See [Cloud](https://docs.alliancecan.ca/wiki/Cloud "Cloud") for how to obtain access to Arbutus.
- [Fir](https://docs.alliancecan.ca/wiki/Fir "Fir"), [Narval](https://docs.alliancecan.ca/wiki/Narval/en "Narval/en"), [Nibi](https://docs.alliancecan.ca/wiki/Nibi "Nibi"), and [Rorqual](https://docs.alliancecan.ca/wiki/Rorqual/en "Rorqual/en") are **general-purpose clusters** (or supercomputers) composed of a variety of nodes including large memory nodes and nodes with accelerators such as GPUs. You can log into any of these using [SSH](https://docs.alliancecan.ca/wiki/SSH "SSH"). A /home directory will be automatically created for you the first time you log in.
- [Trillium](https://docs.alliancecan.ca/wiki/Trillium "Trillium") is a homogeneous cluster (or supercomputer) designed for **large parallel** jobs (>1000 cores).

In this documentation, we generally use the term “cluster” instead of “supercomputer” since it better reflects the architecture of our systems: A large number of individual computers, or “nodes”, linked together as a unit, or “cluster”.

## What system should I use?

This question is hard to answer because of the range of needs we serve and the wide variety of resources we have available. If the descriptions above are insufficient, contact our [technical support](https://docs.alliancecan.ca/wiki/Technical_support "Technical support").

In order to identify the best resource to use, we may ask specific questions, such as:

- What software do you want to use?
	- Does the software require a commercial license?
		- Can the software be used non-interactively? That is, can it be controlled from a file prepared prior to its execution rather than through a graphical interface?
		- Can it run on the Linux operating system?
- How much memory, time, computing power, accelerators, storage, network bandwidth and so forth—are required by a typical job? Rough estimates are fine.
- How frequently will you need to run this type of job?

You may know the answer to these questions or not. If you do not, our technical support team is there to help you find the answers. They will then be able to direct you to the most appropriate resources for your needs.

## What training is available?

Most workshops are organized by the Alliance's regional partners; both online and in-person training opportunities exist on a wide variety of subjects and at different levels of sophistication. We invite you to consult the following regional training calendars and websites for more information,

- WestDRI (Western Canada Research Computing covering both BC and the Prairies regions)
	- [Training Materials website](https://training.westdri.ca/): click on *Upcoming sessions* or browse the menu at the top for recorded webinars
		- [UAlberta ARC Bootcamp](https://www.ualberta.ca/information-services-and-technology/research-computing/bootcamps.html): videos of previous sessions available
- [SHARCNET](https://www.sharcnet.ca/)
- [SciNet](https://www.scinethpc.ca/)
- [Calcul Québec](https://www.calculquebec.ca/en/)
- [ACENET](https://www.ace-net.ca/)

See the complete and merged list of [upcoming training events on Explora](https://explora.alliancecan.ca/events).