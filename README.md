# CHERI Mocha

The CHERI Mocha project is a reference design for an integrated SoC subsystem for secure enclaves that use CHERI.
Secure enclaves are usually part of a larger SoC and are tasked with security critical tasks like user authentication, password storage, etc.
These enclave systems often include application class processors because they need to support an MMU-enabled operating system, usually based on L4 or something clean slate, as opposed to real-time operating systems.
Rich operating systems require virtual memory and page table permissions.
CHERI is an important technology to evaluate in these systems because of the high-level of confidentiality, integrity and availability that is required here.
This open-source design is meant to be a reference for ASICs with any proprietary primitives clearly stubbed out and isolated.
Specifically, any hardware that requires changes with respect to CHERI should be in the open source since this is critical to providing a production-grade CHERI-enabled subsystem that can be integrated into an ASIC.

CHERI Mocha is part of the COSMIC project, which is a collaboration between lowRISC, Capabilities Limited and Oxford University Innovation.
It is work that is funded by Innovate UK and the Department for Science, Innovation and Technology.

