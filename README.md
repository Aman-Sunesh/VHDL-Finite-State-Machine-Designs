# VHDL Finite State Machine Designs

A collection of **Finite State Machine (FSM)** implementations in VHDL.  
Each design models a real-world controller, simulated and verified on FPGA hardware.

---

## Project Contents

- **Street Light Controller**
  - FSM-based design to control a street light sequence.
  - Implements multiple states (e.g., Green, Yellow, Red) with timing transitions.
  - Includes VHDL source, testbench, and FPGA verification.

- **Tail Light Controller**
  - FSM simulating a sequential tail light design (e.g., automotive-style indicators).
  - Demonstrates state transitions and sequential output logic.
  - Includes VHDL source, testbench, and FPGA verification.

---

## Tools & Environment

- **Language:** VHDL  
- **FPGA Board:** Xilinx Basys2 (compatible with other Xilinx boards)  
- **Software:** Xilinx ISE Design Suite  

---

## How to Run

1. Clone this repository:  
   ```bash
   git clone https://github.com/Aman-Sunesh/VHDL-Finite-State-Machine-Designs.git
   cd VHDL-Finite-State-Machine-Designs
   ```

2. Open the desired project folder (e.g., `Street Light Design`) in Xilinx ISE.

3. Add the `.vhd` files and the testbench to a new project.

4. Run simulation to verify state transitions and output behaviour.

5. Synthesize and generate the bitstream.

6. Program the FPGA board to observe the working FSM.

---

## Demonstration

Each FSM is validated through:  
- Simulation waveforms showing state transitions.  
- FPGA demonstration of real-time output behavior.  

---

## License

This repository is shared under the **MIT License**.  
Feel free to explore and adapt these designs for personal learning or projects.

---

## Contact

Developed by **Aman Sunesh**  
- [LinkedIn](https://www.linkedin.com/in/aman-sunesh/)  
- Email: as18181@nyu.edu  

---
