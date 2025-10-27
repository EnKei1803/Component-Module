#!/bin/bash
# Simulation script for running testbenches with Icarus Verilog
# Usage: ./simulate.sh <module_name>

if [ -z "$1" ]; then
    echo "Usage: $0 <module_name>"
    echo "Example: $0 full_adder"
    exit 1
fi

MODULE=$1
SRC_DIR="src"
TB_DIR="tb"
BUILD_DIR="build"

# Create build directory if it doesn't exist
mkdir -p $BUILD_DIR

echo "Compiling $MODULE and its testbench..."

# Compile with Icarus Verilog
iverilog -o $BUILD_DIR/${MODULE}_sim \
    -I$SRC_DIR \
    $SRC_DIR/${MODULE}.v \
    $TB_DIR/${MODULE}_tb.v

if [ $? -eq 0 ]; then
    echo "Compilation successful. Running simulation..."
    
    # Run simulation
    cd $BUILD_DIR
    vvp ${MODULE}_sim
    
    # Check if VCD file was generated
    if [ -f "${MODULE}_tb.vcd" ]; then
        echo "VCD file generated: build/${MODULE}_tb.vcd"
        echo "You can view it with GTKWave: gtkwave build/${MODULE}_tb.vcd"
    fi
    
    cd ..
else
    echo "Compilation failed!"
    exit 1
fi
