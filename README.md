# Component-Module
Essential modules for RTL Design

This repository contains a comprehensive collection of fundamental digital design components implemented in Verilog. These modules are commonly used in hardware design and serve as building blocks for more complex systems.

## 📂 Repository Structure

```
Component-Module/
├── rtl/
│   ├── adder/              # Adder implementations
│   ├── subtractor/         # Subtractor implementations
│   ├── shifter/            # Shifter implementations
│   ├── multiplier/         # Multiplier implementations
│   └── floating_point/     # Floating-point arithmetic
├── testbench/              # Testbenches for verification
└── README.md
```

## 🧮 Available Modules

### Adders
- **Ripple Carry Adder** (`ripple_carry_adder.v`)
  - Simple N-bit adder with carry propagation
  - Good for understanding but slower for large bit widths
  - Includes full adder building block

- **Carry Lookahead Adder** (`carry_lookahead_adder.v`)
  - Faster adder with parallel carry computation
  - Better performance for larger bit widths
  - Uses generate/propagate logic

- **Carry Select Adder** (`carry_select_adder.v`)
  - Hybrid approach with dual computation paths
  - Computes sum for cin=0 and cin=1, then selects
  - Configurable block size for optimization

### Subtractors
- **Subtractor** (`subtractor.v`)
  - Performs A - B using 2's complement addition
  - Supports borrow input/output
  - Includes full subtractor building block

- **Adder-Subtractor** (`adder_subtractor.v`)
  - Combined module for addition and subtraction
  - Mode-controlled operation (0=Add, 1=Subtract)
  - Includes overflow detection for signed operations

### Shifters
- **Barrel Shifter** (`barrel_shifter.v`)
  - Efficient multi-bit shifting in single cycle
  - Supports: logical left/right, arithmetic right, rotate left/right
  - Parameterized shift amount

- **Simple Shifter** (`simple_shifter.v`)
  - Sequential shift register with clock
  - Single-bit shifts per clock cycle
  - Supports serial and parallel I/O

### Multipliers
- **Array Multiplier** (`array_multiplier.v`)
  - Combinational multiplier using partial products
  - Educational design showing multiplication concept
  - Good for understanding but not area-efficient

- **Booth Multiplier** (`booth_multiplier.v`)
  - Implements Booth's radix-2 algorithm
  - Efficient for signed multiplication
  - Reduces number of addition operations

- **Sequential Multiplier** (`sequential_multiplier.v`)
  - State machine-based multiplier
  - Performs multiplication over multiple clock cycles
  - More area-efficient than combinational designs

### Floating-Point Arithmetic
- **IEEE 754 FP Adder** (`fp_adder.v`)
  - Single-precision (32-bit) floating-point addition
  - Handles exponent alignment and normalization
  - Includes overflow/underflow detection

- **Simplified FP Adder** (`fp_adder_simple.v`)
  - 16-bit custom floating-point format
  - Educational implementation
  - Format: Sign (1) | Exponent (5) | Mantissa (10)

## 🚀 Usage

### Module Instantiation Example

```verilog
// Instantiate an 8-bit Ripple Carry Adder
ripple_carry_adder #(.WIDTH(8)) my_adder (
    .a(8'h0F),
    .b(8'h01),
    .cin(1'b0),
    .sum(sum_out),
    .cout(carry_out)
);

// Instantiate a Barrel Shifter
barrel_shifter #(.WIDTH(8)) my_shifter (
    .data_in(8'b11001100),
    .shift_amt(3'd2),
    .shift_type(3'b000),  // Logical left
    .data_out(shifted_data)
);

// Instantiate a Sequential Multiplier
sequential_multiplier #(.WIDTH(8)) my_mult (
    .clk(clk),
    .rst_n(rst_n),
    .start(start_signal),
    .a(8'd5),
    .b(8'd3),
    .product(product_out),
    .done(done_signal)
);
```

## 🧪 Testing

Testbenches are provided in the `testbench/` directory:
- `tb_ripple_carry_adder.v` - Tests basic addition operations
- `tb_barrel_shifter.v` - Tests all shift modes
- `tb_sequential_multiplier.v` - Tests multiplication with timing
- `tb_adder_subtractor.v` - Tests add/subtract modes

### Running Simulations

Using Icarus Verilog:
```bash
# Compile and simulate adder testbench
iverilog -o sim_adder rtl/adder/ripple_carry_adder.v testbench/tb_ripple_carry_adder.v
vvp sim_adder

# Compile and simulate shifter testbench
iverilog -o sim_shifter rtl/shifter/barrel_shifter.v testbench/tb_barrel_shifter.v
vvp sim_shifter

# Compile and simulate multiplier testbench (requires adder)
iverilog -o sim_mult rtl/adder/ripple_carry_adder.v rtl/multiplier/sequential_multiplier.v testbench/tb_sequential_multiplier.v
vvp sim_mult
```

## 📊 Module Characteristics

| Module Type | Latency | Area | Best Use Case |
|-------------|---------|------|---------------|
| Ripple Carry Adder | O(n) | Small | Small bit widths, educational |
| Carry Lookahead | O(log n) | Medium | General purpose, medium widths |
| Carry Select | O(√n) | Medium | High-speed applications |
| Array Multiplier | 1 cycle | Large | When speed is critical |
| Booth Multiplier | 1 cycle | Medium | Signed multiplication |
| Sequential Multiplier | n cycles | Small | Area-constrained designs |

## 🎯 Design Features

- **Parameterized Designs**: Most modules support configurable bit widths
- **Reusable Components**: Modular structure for easy integration
- **Well Documented**: Clear comments explaining functionality
- **Synthesizable**: Compatible with standard FPGA/ASIC synthesis tools
- **Educational**: Includes both simple and optimized implementations

## 🛠️ Requirements

- Verilog HDL simulator (ModelSim, Icarus Verilog, or similar)
- Synthesis tool (optional, for FPGA/ASIC implementation)

## 📝 Notes

- All modules use parameterized designs where applicable
- Testbenches use `timescale 1ns/1ps`
- Modules are written in behavioral/structural Verilog
- Some modules require other modules as dependencies (e.g., subtractor uses ripple_carry_adder)

## 🤝 Contributing

Contributions are welcome! Please ensure:
- Code follows existing style conventions
- New modules include corresponding testbenches
- Documentation is updated accordingly

## 📄 License

This project is open source and available for educational and commercial use.

## 📧 Contact

For questions or suggestions, please open an issue on GitHub.
