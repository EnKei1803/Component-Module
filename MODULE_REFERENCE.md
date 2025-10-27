# Module Quick Reference

## Adders

### ripple_carry_adder
- **File**: `rtl/adder/ripple_carry_adder.v`
- **Parameters**: WIDTH (default: 8)
- **Ports**:
  - Input: a[WIDTH-1:0], b[WIDTH-1:0], cin
  - Output: sum[WIDTH-1:0], cout
- **Description**: N-bit ripple carry adder with sequential carry propagation
- **Dependencies**: full_adder (included in same file)

### carry_lookahead_adder
- **File**: `rtl/adder/carry_lookahead_adder.v`
- **Parameters**: WIDTH (default: 8)
- **Ports**:
  - Input: a[WIDTH-1:0], b[WIDTH-1:0], cin
  - Output: sum[WIDTH-1:0], cout
- **Description**: Fast adder with parallel carry computation
- **Dependencies**: None

### carry_select_adder
- **File**: `rtl/adder/carry_select_adder.v`
- **Parameters**: WIDTH (default: 8), BLOCK_SIZE (default: 4)
- **Ports**:
  - Input: a[WIDTH-1:0], b[WIDTH-1:0], cin
  - Output: sum[WIDTH-1:0], cout
- **Description**: Hybrid adder using dual computation and multiplexing
- **Dependencies**: full_adder (from ripple_carry_adder.v)

## Subtractors

### subtractor
- **File**: `rtl/subtractor/subtractor.v`
- **Parameters**: WIDTH (default: 8)
- **Ports**:
  - Input: a[WIDTH-1:0], b[WIDTH-1:0], borrow_in
  - Output: diff[WIDTH-1:0], borrow_out
- **Description**: Subtractor using 2's complement addition
- **Dependencies**: ripple_carry_adder

### full_subtractor
- **File**: `rtl/subtractor/subtractor.v`
- **Ports**:
  - Input: a, b, bin
  - Output: diff, bout
- **Description**: Single-bit full subtractor
- **Dependencies**: None

### adder_subtractor
- **File**: `rtl/subtractor/adder_subtractor.v`
- **Parameters**: WIDTH (default: 8)
- **Ports**:
  - Input: a[WIDTH-1:0], b[WIDTH-1:0], mode, cin
  - Output: result[WIDTH-1:0], cout, overflow
- **Description**: Combined add/subtract with mode control (0=add, 1=subtract)
- **Dependencies**: carry_lookahead_adder

## Shifters

### barrel_shifter
- **File**: `rtl/shifter/barrel_shifter.v`
- **Parameters**: WIDTH (default: 8)
- **Ports**:
  - Input: data_in[WIDTH-1:0], shift_amt[$clog2(WIDTH)-1:0], shift_type[2:0]
  - Output: data_out[WIDTH-1:0]
- **Description**: Single-cycle multi-bit shifter with multiple modes
- **Shift Types**:
  - 3'b000: Logical left
  - 3'b001: Logical right
  - 3'b010: Arithmetic right
  - 3'b011: Rotate left
  - 3'b100: Rotate right
- **Dependencies**: None

### simple_shifter
- **File**: `rtl/shifter/simple_shifter.v`
- **Parameters**: WIDTH (default: 8)
- **Ports**:
  - Input: clk, rst_n, shift_en, data_in[WIDTH-1:0], load, shift_dir, shift_mode, serial_in
  - Output: data_out[WIDTH-1:0], serial_out
- **Description**: Sequential single-bit shift register
- **Dependencies**: None

## Multipliers

### array_multiplier
- **File**: `rtl/multiplier/array_multiplier.v`
- **Parameters**: WIDTH (default: 8)
- **Ports**:
  - Input: a[WIDTH-1:0], b[WIDTH-1:0]
  - Output: product[2*WIDTH-1:0]
- **Description**: Combinational array multiplier using partial products
- **Dependencies**: ripple_carry_adder

### booth_multiplier
- **File**: `rtl/multiplier/booth_multiplier.v`
- **Parameters**: WIDTH (default: 8)
- **Ports**:
  - Input: a[WIDTH-1:0] (signed), b[WIDTH-1:0] (signed)
  - Output: product[2*WIDTH-1:0] (signed)
- **Description**: Booth's algorithm for efficient signed multiplication
- **Dependencies**: None

### sequential_multiplier
- **File**: `rtl/multiplier/sequential_multiplier.v`
- **Parameters**: WIDTH (default: 8)
- **Ports**:
  - Input: clk, rst_n, start, a[WIDTH-1:0], b[WIDTH-1:0]
  - Output: product[2*WIDTH-1:0], done
- **Description**: Multi-cycle multiplier using shift-and-add
- **Dependencies**: None

## Floating-Point

### fp_adder
- **File**: `rtl/floating_point/fp_adder.v`
- **Parameters**: None (fixed 32-bit IEEE 754)
- **Ports**:
  - Input: a[31:0], b[31:0]
  - Output: result[31:0], overflow, underflow
- **Description**: IEEE 754 single-precision floating-point adder
- **Format**: Sign (1) | Exponent (8) | Mantissa (23)
- **Dependencies**: None

### fp_adder_simple
- **File**: `rtl/floating_point/fp_adder_simple.v`
- **Parameters**: EXP_WIDTH (default: 5), MANT_WIDTH (default: 10)
- **Ports**:
  - Input: a[15:0], b[15:0]
  - Output: result[15:0]
- **Description**: Simplified 16-bit floating-point adder for education
- **Format**: Sign (1) | Exponent (5) | Mantissa (10)
- **Dependencies**: None

## Testbenches

### tb_ripple_carry_adder
- **File**: `testbench/tb_ripple_carry_adder.v`
- **Tests**: Basic addition, carry propagation, edge cases

### tb_barrel_shifter
- **File**: `testbench/tb_barrel_shifter.v`
- **Tests**: All shift modes (logical, arithmetic, rotate)

### tb_sequential_multiplier
- **File**: `testbench/tb_sequential_multiplier.v`
- **Tests**: Various multiplications with timing verification

### tb_adder_subtractor
- **File**: `testbench/tb_adder_subtractor.v`
- **Tests**: Addition, subtraction, overflow detection

## Dependency Graph

```
ripple_carry_adder.v (provides: ripple_carry_adder, full_adder)
    ├── carry_select_adder.v (uses: full_adder)
    ├── subtractor.v (uses: ripple_carry_adder)
    └── array_multiplier.v (uses: ripple_carry_adder)

carry_lookahead_adder.v
    └── adder_subtractor.v (uses: carry_lookahead_adder)

barrel_shifter.v (standalone)
simple_shifter.v (standalone)
booth_multiplier.v (standalone)
sequential_multiplier.v (standalone)
fp_adder.v (standalone)
fp_adder_simple.v (standalone)
```

## Compilation Order

For proper compilation, modules should be compiled in this order to resolve dependencies:

1. `rtl/adder/ripple_carry_adder.v` (provides full_adder and ripple_carry_adder)
2. `rtl/adder/carry_lookahead_adder.v`
3. `rtl/adder/carry_select_adder.v` (depends on full_adder)
4. `rtl/subtractor/subtractor.v` (depends on ripple_carry_adder)
5. `rtl/subtractor/adder_subtractor.v` (depends on carry_lookahead_adder)
6. `rtl/multiplier/array_multiplier.v` (depends on ripple_carry_adder)
7. All other modules (no dependencies)

## Example Compilation Commands

### Using Icarus Verilog:

```bash
# Compile all modules
iverilog -o compiled_design \
  rtl/adder/*.v \
  rtl/subtractor/*.v \
  rtl/shifter/*.v \
  rtl/multiplier/*.v \
  rtl/floating_point/*.v

# Compile and run specific testbench
iverilog -o sim_test \
  rtl/adder/ripple_carry_adder.v \
  testbench/tb_ripple_carry_adder.v
vvp sim_test
```

### Using ModelSim:

```tcl
# Compile all modules
vlog rtl/adder/*.v
vlog rtl/subtractor/*.v
vlog rtl/shifter/*.v
vlog rtl/multiplier/*.v
vlog rtl/floating_point/*.v

# Compile testbench and simulate
vlog testbench/tb_ripple_carry_adder.v
vsim tb_ripple_carry_adder
run -all
```
