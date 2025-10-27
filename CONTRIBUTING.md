# Contributing to Component-Module

Thank you for your interest in contributing to this RTL Design component library! This document provides guidelines for contributing.

## How to Contribute

### Reporting Issues
- Use GitHub Issues to report bugs or request features
- Provide detailed descriptions with examples
- Include simulation results or waveforms when applicable

### Submitting Changes
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-module`)
3. Make your changes following the coding standards below
4. Test your changes thoroughly
5. Commit with clear, descriptive messages
6. Push to your fork and submit a Pull Request

## Coding Standards

### Verilog/SystemVerilog Style Guide

#### Module Structure
```verilog
/**
 * Module: module_name
 * Description: Brief description of functionality
 * 
 * Detailed description of the module's purpose,
 * algorithm, and any important implementation notes.
 * 
 * Author: Your Name
 * Date: YYYY-MM-DD
 * License: MIT
 */

module module_name #(
    parameter WIDTH = 8  // Parameter description
)(
    input  wire clk,        // Clock signal
    input  wire rst_n,      // Active-low reset
    input  wire [WIDTH-1:0] data_in,   // Input data
    output reg  [WIDTH-1:0] data_out   // Output data
);

    // Internal signals
    reg [WIDTH-1:0] internal_reg;
    
    // Module logic here
    
endmodule
```

#### Naming Conventions
- **Modules**: Use lowercase with underscores (e.g., `ripple_carry_adder`)
- **Parameters**: Use UPPERCASE (e.g., `DATA_WIDTH`, `NUM_STAGES`)
- **Signals**: Use lowercase with underscores (e.g., `data_valid`, `addr_out`)
- **Active-low signals**: Suffix with `_n` (e.g., `rst_n`, `enable_n`)
- **Clock signals**: Use `clk` prefix (e.g., `clk`, `clk_div`)

#### Commenting
- Add header comments to all modules
- Comment complex logic blocks
- Explain non-obvious design decisions
- Use inline comments for clarity, not redundancy

#### Testbenches
- Create comprehensive testbenches for all modules
- Test corner cases and boundary conditions
- Include self-checking mechanisms
- Report pass/fail results clearly
- Generate VCD files for waveform viewing

### Directory Structure
```
Component-Module/
├── src/              # Source files (.v, .sv)
├── tb/               # Testbenches (*_tb.v)
├── docs/             # Documentation and specifications
├── examples/         # Example implementations
├── scripts/          # Build and simulation scripts
└── README.md         # Project documentation
```

### Documentation Requirements
- Each module should have a specification document in `docs/`
- Include:
  - Module purpose and overview
  - Interface description (ports and parameters)
  - Timing diagrams (if applicable)
  - Truth tables or state machines
  - Usage examples
  - Performance characteristics

### Testing Requirements
- All modules must have testbenches
- Testbenches should be self-checking when possible
- Include both functional and edge case tests
- Document expected behavior in testbench comments

## Pull Request Process
1. Ensure your code follows the style guide
2. Update documentation for any interface changes
3. Add or update tests as needed
4. Verify all tests pass
5. Update README.md if adding new modules
6. Request review from maintainers

## Module Checklist
Before submitting a new module, ensure:
- [ ] Module follows naming conventions
- [ ] Header comment is complete
- [ ] Code is properly commented
- [ ] Testbench is included and passes
- [ ] Documentation is in docs/
- [ ] Example usage is provided (if applicable)
- [ ] No linting warnings or errors

## Questions?
Feel free to open an issue for any questions about contributing.

## License
By contributing, you agree that your contributions will be licensed under the MIT License.
