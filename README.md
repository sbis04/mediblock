# MediBlock

### [Video demo of the app in action](https://youtu.be/vSe-I6875dU)

An app for sharing electronic health records (EHRs) securely using Blockchain based searchable-encryption scheme.

## Key features

- Uses a **custom encryption** scheme designed by us (based upon multiple research proven concepts - `scroll down to know more`)

- Immune against **quantum attacks**

- **Minimal transaction cost** and low data retrieval/storage time

- Easy to use and **simple app UI** (having all the highly complicated computation stuff in the backend)

> **POINT TO NOTE:** We don't upload the `file` to blockchain, rather just some `data` required for the encryption (keeping the transaction cost low and requires minimal time for retrieving/storing data to blockchain).

## Technology stack

- Flutter
- Dart
- Firebase
- Google Sign In
- Solidity (ethereum smart contract)
- Metamask
- Rinkeby
- Infura
- C++11

## The problem

With more data being pushed to external cloud storage, privacy concerns are usual. Straightforward encryption of uploaded data strips the ability to search over it with some keywords: a highly desirable ability in some use-cases as EMR (Electronic medical records) and IIoT (Industrial Internet of Things). Consequent efforts at constructing post-quantum searchable encryption schemes have failed to resist a curious server launching _inside_ offline keyword guessing attack. Moreover, for every intended receiver, the data owner performs computation separately, implying prior knowledge about recipients. In use-cases, such as EMR, prior knowledge of intended recipients (medical centers) is not true. In this work, we propose a forward-secure searchable encryption scheme that leverages blockchain to take the burden of repetitive computations off the data owner. The proposed scheme resists attacks from an honest-but-curious server and protects the privacy of searches performed.

The scheme used was developed as a part of a research project under Dr. [S.K. Hafizul Islam](https://scholar.google.com/citations?user=ip3ClBIAAAAJ&hl=en&oi=ao) and Dr. [Sherali Zeadally](http://www.uky.edu/~sze223/).

![](https://github.com/sbis04/mediblock/raw/master/screenshots/paper_title.png)

The scheme we developed has the following properties:

- **Post-quantum**: the scheme is secure in post-quantum environments, i.e. it is resistant to attacks from fully developed quantum computers.

- **Forward-secure**: Amongst multiple sessions, if _i_-th session is compromised/hacked, there is guarantee that all to-be-initiated sessions in future are not automatically compromised.

- **Server-blindness**: The server only stores the encrypted EHRs. In no way it is possible for the server to be able to deduce the contents of the EHRs or the search patters employed by medical professionals.

## System model

The scheme has the following participants:

**Trusted Third Party (TTP)**: generates keys for users and performs one-time delivery over secure channel (eg. TLS) Initializes system parameters

**Data Owner (DO)**: Someone who stores their medical history on the server. For instance, a patient.

**Data User (DU)**: Someone, liks a medical professional, who uses DO’s history.

**Cloud Server (CS)**: The government approved server in our previous slides, where the EHRs are stored

**Ledger**: A decentralized blockchain network that enables the DO to encrypt data once and let any authorized doctor use it.

![](https://github.com/sbis04/mediblock/raw/master/screenshots/system_model.png)

![](https://github.com/sbis04/mediblock/raw/master/screenshots/mediblock_interfacing.png)

## Wireframe (with some description)

![](https://github.com/sbis04/mediblock/raw/master/screenshots/mediblock_wireframe.png)

## Initial planning

![](https://github.com/sbis04/mediblock/raw/master/screenshots/mediblock_planning.jpg)

## Plugins

- [firebase_core](https://pub.dev/packages/firebase_core)
- [firebase_auth](https://pub.dev/packages/firebase_auth)
- [google_sign_in](https://pub.dev/packages/google_sign_in)
- [cloud_firestore](https://pub.dev/packages/cloud_firestore)
- [firebase_storage](https://pub.dev/packages/firebase_storage)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
- [file_picker](https://pub.dev/packages/file_picker)
- [web3dart](https://pub.dev/packages/web3dart)
- [http](https://pub.dev/packages/http)
- [path_provider](https://pub.dev/packages/path_provider)
- [permission_handler](https://pub.dev/packages/permission_handler)
- [open_file](https://pub.dev/packages/open_file)

## License

Copyright (c) 2020 Bharat Keswani, Nimish Mishra, Souvik Biswas

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
