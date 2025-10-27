# Full Adder Module Specification

## Overview
The full adder is a fundamental digital logic component that adds three single-bit binary numbers: two operand bits and a carry-in bit. It produces two outputs: a sum bit and a carry-out bit.

## Module Interface

### Inputs
- `a` (1-bit): First operand bit
- `b` (1-bit): Second operand bit  
- `cin` (1-bit): Carry input from previous stage

### Outputs
- `sum` (1-bit): Sum of the three input bits (XOR operation)
- `cout` (1-bit): Carry output to next stage

## Truth Table

| a | b | cin | sum | cout |
|---|---|-----|-----|------|
| 0 | 0 | 0   | 0   | 0    |
| 0 | 0 | 1   | 1   | 0    |
| 0 | 1 | 0   | 1   | 0    |
| 0 | 1 | 1   | 0   | 1    |
| 1 | 0 | 0   | 1   | 0    |
| 1 | 0 | 1   | 0   | 1    |
| 1 | 1 | 0   | 0   | 1    |
| 1 | 1 | 1   | 1   | 1    |

## Boolean Equations

**Sum**: `sum = a ⊕ b ⊕ cin`

**Carry Out**: `cout = (a·b) + (b·cin) + (a·cin)`

Or simplified using majority function: `cout = MAJ(a, b, cin)`

## Applications
- Building blocks for ripple carry adders
- Carry lookahead adders
- Multi-bit arithmetic units
- ALU implementations

## Implementation Notes
- Uses combinational logic only (no clock)
- Zero propagation delay in simulation
- Can be cascaded to create N-bit adders
- Forms the basis for more complex arithmetic circuits

## Testing
See `tb/full_adder_tb.v` for comprehensive testbench that verifies all 8 input combinations.

## Performance
- Critical path: Through XOR and OR gates
- Typical gate delay: 2-3 gate delays
- Can be optimized using different logic families

## References
- Digital Design and Computer Architecture by Harris & Harris
- Computer Organization and Design by Patterson & Hennessy
