# Component-Module


Essential, reusable RTL building blocks written in SystemVerilog for arithmetic and datapath design: adders, comparators, multipliers, floating-point components, and universal shifters.


Language: SystemVerilog  
Status: Active Development (WIP)


---


## Why this repository exists


- Centralized collection of reusable arithmetic and datapath modules.
- Simple, parameterized designs for easy integration into larger SoC or FPGA projects.
- Compatible with both open-source (Verilator, OSS-CAD-Suite) and commercial EDA tools.


---


## Repository Structure


Component-Module

 ├─ adder/               # Integer adders (Ripple, CLA, Kogge-Stone, etc.)
 ├─ comparator/          # Word comparators (==, !=, <, >, <=, >=)
 ├─ floating point/      # FP primitives and adder components
 ├─ multiplier/          # Integer multipliers (Iterative, Wallace tree, Booth, etc.)
 ├─ universial shifter/  # Logical, arithmetic, rotate shifters
 └─ README.md


---


## Getting Started


### 1. Clone the repository
git clone https://github.com/EnKei1803/Component-Module.git

cd Component-Module

### 2. Simulate with Verilator
verilator -Wall --cc adder/adder.sv --exe tb/tb_adder.cpp

make -C obj_dir -f Vadder.mk Vadder

./obj_dir/Vadder

### 3. Simulate with Icarus Verilog
iverilog -g2012 -o sim.out adder/adder.sv tb/tb_adder.sv

vvp sim.out

Tip: Create a simple "tb" directory with self-checking testbenches for each module.

---

## Module Overview

### Adder (adder/)
Purpose: High-speed or area-efficient integer addition.  
Variants: Ripple-carry, Carry-lookahead, Kogge-Stone, etc.  
Parameters: WIDTH (default 32)  
Signals: a, b, cin, sum, cout, ovf  

### Comparator (comparator/)
Purpose: Signed and unsigned comparison logic.  
Parameters: WIDTH  
Outputs: eq, lt, gt, le, ge  

### Multiplier (multiplier/)
Purpose: Integer multiplication.  
Variants: Iterative, Booth, Wallace Tree  
Parameters: WIDTH, SIGNED  
Outputs: Product (2*WIDTH) or truncated  

### Universal Shifter (universial shifter/)
Purpose: Logical/Arithmetic shift and rotation.  
Parameters: WIDTH  
Signals: data_in, shamt, mode, data_out  

### Floating Point (floating point/)
Purpose: IEEE-754 compatible floating-point adder and helpers (align, normalize, denormalize).  
Parameters: EXP, FRAC (e.g., 8/23 for FP32)  
Features: Handles NaN, INF, Zero, and RNE rounding.

---

## Verification Guidelines

- Use self-checking testbenches with assertions.
- Include directed and randomized tests.
- Verify corner cases: carry, overflow, shift extremes, FP subnormals/NaNs/Infs.
- Lint with Verilator or commercial tools:
  verilator -Wall -Wno-UNOPTFLAT ...
- Use --trace or $dumpvars for waveform generation.

---

## Synthesis Notes

- Use always_ff and always_comb properly.
- Parametrize widths instead of hardcoding.
- Prefer unique case and priority if for clarity.
- Consider pipelining for floating-point modules.

---

## Roadmap

- [ ] Add complete testbenches for each module.
- [ ] Document all ports and parameters in detail.
- [ ] Add Yosys or vendor synthesis scripts.
- [ ] Add GitHub Actions CI for lint + simulation.
- [ ] Add open-source license (MIT/BSD recommended).

---

## Contributing

1. Fork and create a feature branch (feat/<module> or fix/<module>).
2. Add/extend testbenches with pass/fail criteria.
3. Run lint and simulation locally.
4. Submit a Pull Request with a short description.

---

## License

No license file yet. Consider adding MIT or BSD-3-Clause for open-source usage.

---

## Acknowledgments

- Inspired by standard RTL practices in open-source hardware communities.
- Structured for easy integration with SoC and FPGA projects.
