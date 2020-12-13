# MediBlock

An app for sharing electronic health records (EHRs) securely using Blockchain based searchable-encryption scheme.

## The problem

With more data being pushed to external cloud storage, privacy concerns are usual. Straightforward encryption of uploaded data strips the ability to search over it with some keywords: a highly desirable ability in some use-cases as EMR (Electronic medical records) and IIoT (Industrial Internet of Things). Consequent efforts at constructing post-quantum searchable encryption schemes have failed to resist a curious server launching *inside* offline keyword guessing attack. Moreover, for every intended receiver, the data owner performs computation separately, implying prior knowledge about recipients. In use-cases, such as EMR, prior knowledge of intended recipients (medical centers) is not true. In this work, we propose a forward-secure searchable encryption scheme that leverages blockchain to take the burden of repetitive computations off the data owner. The proposed scheme resists attacks from an honest-but-curious server and protects the privacy of searches performed.

The scheme used was developed as a part of a research project under Dr. [S.K. Hafizul Islam](https://scholar.google.com/citations?user=ip3ClBIAAAAJ&hl=en&oi=ao) and Dr. [Sherali Zeadally](http://www.uky.edu/~sze223/).

![](https://github.com/sbis04/mediblock/raw/master/screenshots/paper_title.png)

The scheme we developed has the following properties:

- **Post-quantum**: the scheme is secure in post-quantum environments, i.e. it is resistant to attacks from fully developed quantum computers.

- **Forward-secure**: Amongst multiple sessions, if *i*-th session is compromised/hacked, there is guarantee that all to-be-initiated sessions in future are not automatically compromised.

- **Server-blindness**: The server only stores the encrypted EHRs. In no way it is possible for the server to be able to deduce the contents of the EHRs or the search patters employed by medical professionals.

## System model

The scheme has the following participants:

**Trusted Third Party (TTP)**: generates keys for users and performs one-time delivery over secure channel (eg. TLS) Initializes system parameters

**Data Owner (DO)**: Someone who stores their medical history on the server. For instance, a patient.

**Data User (DU)**: Someone, liks a medical professional, who uses DO’s history.

**Cloud Server (CS)**: The government approved server in our previous slides, where the EHRs are stored

**Ledger**: A decentralized blockchain network that enables the DO to encrypt data once and let any authorized doctor use it. 

![](https://github.com/sbis04/mediblock/raw/master/screenshots/system_model.png)

## Wireframe (with some description)

![](https://github.com/sbis04/mediblock/raw/master/screenshots/mediblock_wireframe.png)

## Initial planning

![](https://github.com/sbis04/mediblock/raw/master/screenshots/mediblock_planning.jpg)