# PCIe_GEN5_Verification

# 1. Introduction
This project focuses on verifying the PCIe Gen5 Physical Layer, originally designed by a team from Ain Shams University in previous years. The goal is to ensure protocol correctness, reliability, and robustness of the physical layer implementation through thorough verification.

To achieve this, we developed a UVM-based verification environment capable of simulating and checking complex PCIe Gen5 behaviors. The environment includes a scoreboard, functional coverage, and a set of carefully crafted assertions to validate the following aspects:

Correct LTSSM (Link Training and Status State Machine) transitions

TLP (Transaction Layer Packet) transmission and reception behavior

Timeout detection for each LTSSM substate to ensure the design doesn't get stuck

The verification was initially performed on a 16-lane configuration with a 32-bit PIPE interface width, which matches Gen5 performance and complexity expectations.

To expand the test coverage and realism, we also integrated two instances of the DUT in the environment — one acting as the Upstream Port and the other as the Downstream Port. This dual-device setup allows us to verify both roles of the PCIe link simultaneously, ensuring bidirectional correctness and complete link bring-up behavior between two fully functional endpoints.

# 2-Testbench Architectures
<img width="1873" height="228" alt="image" src="https://github.com/user-attachments/assets/048e100d-abef-4900-8526-9c9a01e8f585" />

# 2.1 UVM Components 

# Tx and Rx Slaves
These components are responsible for validating the correctness of the Training Set (TS) symbols exchanged between the Upstream and Downstream DUTs. They help ensure that both ends of the link follow the PCIe protocol during initialization and link training phases. By monitoring TS sequences, we confirm that both DUTs are synchronized and progressing through the LTSSM as expected.

# PIPE Scoreboard
The PIPE scoreboard collects transactions from the PIPE monitors and verifies several aspects: the correctness of the exchanged TS sequences, the count of each TS type, and the LTSSM state transitions. This component serves as a key checker that compares the observed behavior of the DUT against the expected protocol behavior defined by PCIe Gen5 specifications.

# PIPE Coverage Collector
This component is designed to monitor the LTSSM transitions and evaluate whether all required transitions and corner cases have been exercised. Additionally, it records the types of TS symbols sent and checks for timeout conditions within each LTSSM substate. This helps ensure that the DUT does not get stuck in any specific substate and that all critical protocol paths are covered.

# TX Master Driver
The TX master driver is responsible for generating and sending TLP (Transaction Layer Packets) and DLLP (Data Link Layer Packets) sequences to the DUT. These sequences mimic real-world PCIe traffic and allow us to verify how the DUT processes incoming protocol packets under different scenarios.

# Tx LTSSM Driver
This driver is focused on LTSSM state control. It drives specific sequences such as LinkUp requests and other LTSSM state transition triggers. This allows us to test how the DUT handles state transitions under controlled conditions and ensures compliance with the expected LTSSM flow.

# TX and RX Master Monitors
These monitors observe TLP and DLLP traffic sent by the DUT. They collect packets and pass them to the scoreboard for further analysis. By capturing real-time traffic from both ends, the monitors help validate the communication between devices and provide visibility into packet-level interactions.

# LPIF Scoreboard
The LPIF scoreboard checks the correctness of TLP and DLLP packets on the LPIF (Link Protocol Interface). It ensures that the packets generated and received through this interface conform to the expected format and content, thus validating the data integrity and protocol logic at the transaction and link layers.

# LPIF Coverage Collector
This component focuses on coverage analysis of the LPIF interface. It tracks different scenarios and variations in TLP and DLLP transmissions to verify functional diversity. The goal is to ensure the DUT handles a wide range of traffic patterns and edge cases across the LPIF boundary.

# Adapter
The Adapter component is used to inject controlled errors into the data exchanged between the Upstream and Downstream devices. Positioned between the two DUTs, it intercepts the PIPE interface traffic and modifies selected fields in the Training Sets, TLPs, or DLLPs to introduce protocol violations or corruptions. This allows us to test how both devices handle real-time errors, including error detection, reporting, and recovery mechanisms, thereby enhancing the robustness of the verification environment.

# 3. Driven Sequences
In our UVM environment, we implemented three core sequences that are essential for verifying the behavior of the PCIe Gen5

# 3.1 LinkUp Sequence
The LinkUp sequence initiates the LTSSM flow to establish a stable link between the Upstream and Downstream DUTs. It drives the required Training Sets (TS1 and TS2) according to the PCIe specification and monitors the transitions through the LTSSM states until both DUTs reach the L0 (Link Up) state. This sequence ensures the DUTs can correctly negotiate link parameters and synchronize reliably at Gen5 speed.

# 3.2 TLP and DLLP Transmission Sequence
This sequence is responsible for driving Transaction Layer Packets (TLPs) and Data Link Layer Packets (DLLPs) between the two DUTs after achieving LinkUp. It helps verify the end-to-end communication behavior, packet formatting, acknowledgment handling, and flow control. The sequence mimics real PCIe traffic, covering common packet types such as memory read/write and flow control updates.

# 3.3 Error Injection Sequence
To test robustness and error-handling capabilities, we implemented an error injection sequence using a custom UVM adapter. This sequence introduces protocol violations, malformed packets, or timing violations at specific points in the transmission. It allows us to verify whether the DUT correctly detects, reports, and recovers from errors as per the PCIe Gen5 specifications.

# 4 Results
Our verification campaign produced strong coverage metrics, confirming the reliability and correctness of the PCIe Gen5 Physical Layer design:

# Code Coverage:
We achieved approximately 94% statement code coverage. Some portions of the RTL code were excluded using a .do file. This is because the design is written generically to support multiple configurations (e.g., 1, 4, 16, and 32 lanes, with different PIPE widths). However, in our verification environment, only a fixed configuration was tested (16 lanes, 32-bit PIPE), which left some configuration-specific branches unused, resulting in dead code that was safely excluded from coverage.
<img width="2427" height="212" alt="image" src="https://github.com/user-attachments/assets/824e1969-fcf3-41dc-9c3f-bc73be02fa00" />

# Functional Coverage: 
We reached around 98% functional coverage. The slight gap is due to a specific LTSSM substate that did not trigger a timeout condition during simulation, leaving a coverage point uncovered.
<img width="1349" height="422" alt="TX Upstream Exchange" src="https://github.com/user-attachments/assets/b1ca0ee8-7221-46c9-a778-d231c0a57f00" />
<img width="1294" height="339" alt="Tx Downstream OS" src="https://github.com/user-attachments/assets/d7e209a2-ea75-4046-8457-a453a1577f65" />
<img width="1330" height="447" alt="TX Downstream Exchange" src="https://github.com/user-attachments/assets/82b141ed-a64a-4038-b029-5d67f847dd11" />
<img width="867" height="611" alt="summary" src="https://github.com/user-attachments/assets/787ee14e-c940-4141-bb95-16fc85e0470a" />
<img width="1343" height="237" alt="sb Tlp pkt" src="https://github.com/user-attachments/assets/f47cd2f0-e6b6-4812-ae9b-62db3fb6fc35" />
<img width="1143" height="480" alt="Rx_transistion Up" src="https://github.com/user-attachments/assets/252afafd-a635-462c-9537-a69821868dd7" />
<img width="1205" height="488" alt="Rx_transistion Down" src="https://github.com/user-attachments/assets/e11041a5-4695-4fd8-a3c9-e163f8844b21" />
<img width="1277" height="416" alt="RX Upstream Exchange" src="https://github.com/user-attachments/assets/73aee01d-6047-4332-9aca-3e87908855fa" />
<img width="1285" height="354" alt="Rx Downstream OS" src="https://github.com/user-attachments/assets/b1712fb1-9e2e-4f36-aef5-ee7f494e8926" />
<img width="1307" height="520" alt="RX Downstream Exchange" src="https://github.com/user-attachments/assets/7f6ee817-76bc-494d-8303-1049ad657c8b" />
<img width="1366" height="84" alt="Covearage" src="https://github.com/user-attachments/assets/0695f9ac-27d6-4a09-bf65-888ccddfa64a" />
<img width="1067" height="450" alt="Tx_transistion Up" src="https://github.com/user-attachments/assets/bab25a8b-79d9-4991-b4d9-de52f2b65054" />
<img width="1104" height="485" alt="Tx_transistion Down" src="https://github.com/user-attachments/assets/b0497b83-b5c5-4b77-a998-d1244b917c11" />


# Assertions:
We implemented several key assertions to validate both input and output signal correctness. These assertions helped catch protocol violations, incorrect transitions, and signal-level mismatches early in the simulation process.

# 5-Found Bugs
During the verification process, we identified approximately 42 to 45 functional bugs in the original PCIe Gen5 Physical Layer design. These bugs were detected through a combination of stimulus-driven sequences, assertions, and scoreboard checks.

We successfully resolved around 85% to 90% of the reported bugs in collaboration with the design team. The remaining issues are either low-priority or related to unverified configurations (e.g., alternative lane widths or PIPE interface sizes) not covered in the current test plan

<img width="1284" height="1195" alt="image" src="https://github.com/user-attachments/assets/ca0e3934-12ff-4993-948a-535c9e4ee6cd" />
<img width="1254" height="1199" alt="image" src="https://github.com/user-attachments/assets/d4411940-08c5-4b5e-b73f-c9d48ace4f56" />
<img width="1190" height="1213" alt="image" src="https://github.com/user-attachments/assets/9f8e1b46-f323-4947-a3b4-1f387ae10613" />
<img width="1345" height="1208" alt="image" src="https://github.com/user-attachments/assets/38397dfc-d302-46bf-aa63-6df470659124" />



