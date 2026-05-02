---
title: "Infrastructure renewal - Alliance Doc"
source: "https://docs.alliancecan.ca/wiki/Infrastructure_renewal"
author:
published: 2025-09-29
created: 2026-04-28
description:
tags:
  - "clippings"
---
## Major upgrade of our Advanced Research Computing infrastructure

The Advanced Research Computing infrastructure renewal began in winter 2024–2025 and new systems were made available to users throughout 2025 and early 2026. These changes have improved High Performance Computing (HPC) and Cloud services for Canadian researchers. Migration and decommissioning activities remain ongoing for some systems. This page will continue to be updated with information related to the transition.

The infrastructure renewal has replaced nearly 80% of the equipment that had been approaching end-of-life. The new systems provide faster processing speeds, greater storage capacity, and improved reliability.

## System details

| **Documentation** | **Old System to be Replaced** |
| --- | --- |
| [Arbutus](https://docs.alliancecan.ca/wiki/Arbutus "Arbutus") | [Cloud](https://docs.alliancecan.ca/wiki/Cloud "Cloud") (as a virtual infrastructure there is no change to the cloud interface.) |
| [Rorqual](https://docs.alliancecan.ca/wiki/Rorqual/en "Rorqual/en") | [Béluga](https://docs.alliancecan.ca/wiki/Beluga/en "Beluga/en") |
| [Fir](https://docs.alliancecan.ca/wiki/Fir "Fir") | [Cedar](https://docs.alliancecan.ca/wiki/Cedar "Cedar") |
| [Trillium](https://docs.alliancecan.ca/wiki/Trillium "Trillium") | Niagara & [Mist](https://docs.alliancecan.ca/wiki/Mist "Mist") |
| [Nibi](https://docs.alliancecan.ca/wiki/Nibi "Nibi") | [Graham](https://docs.alliancecan.ca/wiki/Graham "Graham") |

## System capacity, reductions and outages

During the installation and the transition to the new infrastructure, outages and reductions will be unavoidable due to constraints on space and electrical power. We recommend that you consider the possibility of outages when you plan research programs, graduate examinations, etc.

For a list of completed events, please see [Infrastructure renewal completed events](https://docs.alliancecan.ca/wiki/Infrastructure_renewal_completed_events "Infrastructure renewal completed events").

| **Start Time** | **End Time** | **Status** | **System** | **Type** | **Description** |
| --- | --- | --- | --- | --- | --- |
| April 7, 2026 | August 31, 2026 | In Progress | Arbutus | Upgrade / Migration | The upgraded **Arbutus Cloud** is now in production and available to RAC 2026–2027 recipients.  **Actions Required**  - Both RAC recipients and RAS users with a 2025–2026 allocation on legacy Arbutus are responsible for migrating existing resources before August 31, 2026. - Migration may begin as soon as access to the new Arbutus Cloud is available. - 2025–2026 RAC allocations will remain active on legacy Arbutus during the migration period. - Projects with existing Arbutus RAS Cloud allocations must submit a request to [cloud@tech.alliancecan.ca](mailto:cloud@tech.alliancecan.ca) to be added to the provisioning queue. Provisioning is performed in bulk and delays may occur before access is available.  **What’s Different**  - The new Arbutus Cloud introduces single sign-on (SSO) authentication with multi-factor authentication (MFA). - Users must select “Authenticate using Digital Research Alliance of Canada” when logging in.  **Documentation**  - [Arbutus Migration Guide](https://docs.alliancecan.ca/wiki/Arbutus_Migration_Guide) - [Multifactor Authentication](https://docs.alliancecan.ca/wiki/Multifactor_authentication)  For access: [Arbutus Cloud](https://arbutus.alliancecan.ca/) |
| January 2026 | June 20, 2026 | In Progress | Béluga | Decommissioning | The **Béluga** compute service, which was stopped with the deployment of **Rorqual**, will not return to service. No restoration or reactivation is planned.  **Storage shutdown**  - **January 2026** – Storage quotas on `/project`, `/home`, `/scratch`, and `/nearline`  will be reduced to allow data deletion or archiving only. This provides a six-month window to extract and migrate files.  - **February 28, 2026** – The temporary storage system ( `/scratch`) will be decommissioned. All critical files must be moved before this date. - **June 20, 2026** – Access to all remaining data will end.  **Note**  - Béluga Cloud (\`beluga-cloud\`) is a separate infrastructure and is not impacted by the decommissioning of the Béluga compute cluster. |
| Sept 30, 2025 | Sept 30, 2025 | Completed | Niagara | End of Service | On September 30, 2025, the **Niagara** compute cluster was retired.  For migration guidance, see: [Transition from Niagara to Trillium](https://docs.alliancecan.ca/wiki/Transition_from_Niagara_to_Trillium). |
| Sept 16, 2025 | Sept 30, 2025 | Completed | Mist | End of Service | On September 16, 2025, the **Mist** compute cluster was retired.  Please transition new work to **Trillium**. See: [Trillium Quickstart](https://docs.alliancecan.ca/wiki/Trillium_Quickstart). |
| Sept 12, 2025 | Sept 12, 2025 | Completed | Cedar | End of Service | On September 12, 2025, the **Cedar** compute cluster was retired.  **Data Access**  - Files stored on **Cedar** are already available on **Fir** because the two clusters share the same file systems. No action is required regarding your stored files.  Starting September 12, please submit your jobs to another cluster on our [new national infrastructure](https://docs.alliancecan.ca/wiki/National_systems "National systems"), including **Fir**. |
| Sept 1, 2025 | Sept 2, 2025 | Completed | Graham | End of Service | On September 1, 2025, the **Graham** compute cluster was retired.  **Data Access**  - Files stored on **Graham** are already available on **Nibi** because the two clusters share the same file systems. No action is required regarding your stored files.  Starting September 1, please submit your jobs to another cluster on our [new national infrastructure](https://docs.alliancecan.ca/wiki/National_systems "National systems"), including **Nibi**. |

## Resource Allocation Competition (RAC)

The [Resource Allocation Competition](https://docs.alliancecan.ca/wiki/Resource_Allocation_Competition "Resource Allocation Competition") will be impacted by this transition, but the application process remains the same.  
2024/25 allocations will remain in effect on retiring clusters while each cluster remains in service. The 2025/26 allocations will be implemented everywhere once all new clusters are in service.  
Because the old clusters will mostly be out of service before all new ones are available, if you hold both a 2024 and a 2025 RAC award you will experience a period when neither award is available to you. You will be able to compute with your default allocation (`def-xxxxxx`) on each new cluster as soon as it goes into service, but the 2025 RAC allocations will only become available when all new clusters are in service.

## User training resources

Discover more training opportunities through [Explora](https://explora.alliancecan.ca/).

| **Course Title** | **Course Provider** | **Instructor** | **Date** | **Description** | **Audience** | **Format** | **Registration** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Introduction to HPC on Alliance Clusters (3-part series) | Simon Fraser University (SFU) / West DRI | Alex Razoumov | Thursdays: September 25, October 2 & October 9, 2025, 10:00 AM PT (2 hours each) | Intro to HPC on Alliance clusters: hardware overview; tools & software environment; brief tour of OpenMP, MPI, HPC Python (Dask, Ray), Chapel, Julia; compiling serial/shared/distributed codes; using Slurm (batch & interactive), benchmarking, submitting many jobs, estimating resources, and managing permissions. Includes demos and hands-on exercises on a training cluster. | New or prospective HPC users on Canada's DRI systems | Webinar series (3 × 2-hour sessions) | Past |
| [HPC105: Intro to SciNet and Trillium](https://education.scinet.utoronto.ca/enrol/index.php?id=1389) | SciNet | SciNet Education Team | Available Anytime (updated August 2025) | Self-guided course on using SciNet systems (Trillium): account set-up, first login, and running computations. For returning users from legacy systems (Niagara, Mist), includes workflow migration guidance to Trillium. | Prospective users of [Trillium](https://docs.alliancecan.ca/wiki/Trillium) and New users to SciNet | Self-guided online course (Estimated time: ~4 hours) | [Access the course here/Alliance CCDB account is required](https://education.scinet.utoronto.ca/enrol/index.php?id=1389) |
| [Migrating to the upgraded national systems](https://youtu.be/nRX8zTIVEXk) | SHARCNET | Sergey Mashchenko | Wednesday, July 30, 2025, 12:00pm EDT | Most of the Alliance national systems have been undergoing a major upgrade during this spring and summer. They have been effectively rebuilt from scratch using up-to-date hardware, bringing a significant increase in computing capacity, memory, and storage to the users. The upgraded clusters have new names: Graham became Nibi, Beluga - Rorqual, Cedar - Fir, Niagara - Trillium. (The remaining cluster - Narval - is not having an upgrade this cycle.) Some of the upgraded systems are already online, not at a full capacity yet. The plan is to make all of them available by the end of July.      This webinar is to address the concerns and questions the users of the existing systems might have. How will the upgrade affect my workflow? Are there significant changes to the way the job scheduling and file systems operate in the new clusters? How to make the best use of the increased computing capacity of the upgraded clusters, in particular in regards of the computing nodes becoming much "fatter" (many more cpu cores per node)? As the most significant change will happen to the way the GPU computing is done, the webinar will cover this in detail.      There will be time for questions at the end, please bring your questions and concerns. | Prospective users of the upgraded systems | Webinar; recordings and materials from previous SHARCNET webinars are available at [http://youtube.sharcnet.ca](http://youtube.sharcnet.ca/). | Past |
| Workflow Hacks for Large Datasets in HPC | Simon Fraser University (SFU) / West DRI | Alex Razoumov | Tuesday, May 20, 2025, 10:00 AM PT | Over the years, we have delivered webinars on tools that can significantly enhance research workflows involving large datasets. In this session, we will highlight some of these valuable tools:   • **In-situ visualization:** enables interactive rendering of large in-memory arrays without the need to store them to disk.   • **Lossy 3D data compression:** reduces the size of 3D datasets by up to 100X with no visible artifacts, making it ideal for storage and archival.   • **Distributed storage:** helps manage vast amounts of data across multiple locations.   • **DAR (Disk ARchiver):** a modern, high-performance alternative to TAR that offers indexing, differential archives, and faster extraction. | Users working with large datasets | Webinar;   Recordings and materials from previous related webinars are freely available at [https://training.westdri.ca](https://training.westdri.ca/). | Past |
| [Mastering GPU Efficiency](https://training.sharcnet.ca/courses/enrol/index.php?id=210) | SHARCNET | Sergey Mashchenko | Available Anytime | This online self-paced course provides basic training for [Alliance](https://training.sharcnet.ca/courses/mod/glossary/showentry.php?eid=112&displayformat=dictionary) users on using GPUs on our [national systems](https://training.sharcnet.ca/courses/mod/glossary/showentry.php?eid=86&displayformat=dictionary). Modern GPUs (such as NVIDIA A100 and H100) are massively parallel and very expensive devices. Most of GPU jobs are incapable of utilizing these GPUs efficiently, either due to the problem size being too small to saturate the GPU, or due to the intermittent (bursty) GPU utilization pattern. This course will teach you how to measure the GPU utilization of your jobs on our clusters, and show how to use the two NVIDIA technologies - MPS (Multi-Process Service) and MIG (Multi-Instance GPU) - to improve GPU utilization. | Prospective users of the upgraded systems | 1-hour self-paced online course with a certificate of completion | [Access the course here/Alliance CCDB account is required](https://training.sharcnet.ca/courses/enrol/index.php?id=210) |
| Introduction to the Fir cluster | Simon Fraser University (SFU) / West DRI | Alex Razoumov | September 16, 2025 | SFU’s newest cluster, Fir, became available during August 2025. In this webinar, we will give an overview of the cluster and its hardware, walk through the filesystems and their recommended usage, and talk about job submission policies and overall best practices for using the cluster. | Prospective users of the [Fir](https://docs.alliancecan.ca/wiki/Fir "Fir") cluster | Webinar;   Recordings and materials from previous related webinars are available at [West DRI – Getting Started (HPC)](https://training.westdri.ca/getting-started/#high-performance-computing). | Past |
| [Survival guide for the upcoming GPU upgrades](https://youtu.be/pxY3G3BhwyA) | SHARCNET | Sergey Mashchenko | Wednesday, November 20, 2024, 12:00 PM to 1:00 PM ET | In the coming months, national systems will be undergoing significant upgrades. In particular, older GPUs (P100, V100) will be replaced with the newest H100 GPUs from NVIDIA. The total GPU computing power of the upgraded systems will grow by a factor of 3.5, but the number of GPUs will decrease significantly (from 3200 to 2100). This will present a significant challenge for users, as the usual practice of using a whole GPU for each process or MPI rank will no longer be feasible in most cases. Fortunately, NVIDIA provides two powerful technologies that can be used to mitigate this situation: MPS (Multi-Process Service) and MIG (Multi-Instance GPU). The presentation will walk the audience through both technologies and discuss the ways they can be used on the clusters. The discussion will include how to determine which approach will work best for specific code, and a live demonstration will be given at the end. | Prospective users of the upgraded systems. Users intending to use a substantial amount of H100 resources (e.g., more than one GPU at a time, and/or over 24 hours runtime) | 1-hour [presentation](https://youtu.be/pxY3G3BhwyA) and [slides](https://helpwiki.sharcnet.ca/wiki/images/1/1d/MIG_MPS.pdf) | Past |

## Frequently asked questions

## Will my data be copied to its new system?

Data migration to the new systems is the responsibility of each National Host Site who will inform you of what you need to do.

## Will my files be deleted when a system is undergoing a complete data center shutdown as part of renewal activities?

No, your files will not be deleted. During renewal activities, each National Host Site will migrate /project and /home data from the existing storage system to the new storage system once it is installed. These migrations typically occur during outages, but specific details may vary by National Host Site. Each National Host Site will keep users informed of any specific, user-visible effects. Additionally, tape systems for backups and /nearline data are not being replaced, so backups and /nearline data will remain unchanged. For further technical questions, please email [technical support](https://docs.alliancecan.ca/wiki/Technical_support "Technical support"). This goes directly to our ticketing system, where a support expert can provide a detailed response.

## When will outages occur?

Each National Host Site will have its own schedule for outages as the installation of and transition to new equipment proceeds. As usual, specific outages will be described on [our system status web page](https://status.alliancecan.ca/). We will provide more general updates on this wiki page and you will periodically receive emails with updates and outage notices.

## Whom can I contact for questions about the transition?

Contact our [technical support](https://docs.alliancecan.ca/wiki/Technical_support "Technical support"). They will try their best to answer any questions they can.

## Will my jobs and applications still be able to run on the new system?

Generally yes, but the new CPUs and GPUs may require recompilation or reconfiguration of some applications. More details will be provided as the transition unfolds.

## Will the software from the current systems still be available?

Yes, our [standard software environment](https://docs.alliancecan.ca/wiki/Standard_software_environments "Standard software environments") will be available on the new systems.

## Will commercial, licensed software be migrated to the new systems?

Yes, the plan is that the current commercial software licenses will be transitioned from an old system to the new replacement so to the extent possible users should see identical access to those special applications (Gaussian, AMS/ADF, etc.). There is a small risk that the software providers will change their licensing terms for the new system. Such issues will be addressed individually as they come up.

## Will there be staggered outages?

We will do our best to limit overlapping outages, but because we are very constrained by delivery schedules and funding deadlines, there will probably be periods when several of our systems are simultaneously offline. Outages will be announced as early as possible.

## Can I purchase old hardware after equipment upgrades?

Most of the equipment is legally the property of the hosting institution. When the equipment is retired, the host institution manages its disposal following that institution's guidelines. This typically involves "e-cycling"--- recycling the equipment rather than selling it. If you're looking to acquire the old hardware, it's best to contact the host institution directly, as they may have specific policies or options for selling equipment.