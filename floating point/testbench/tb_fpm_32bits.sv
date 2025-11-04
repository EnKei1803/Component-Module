`timescale 1ns/1ns
// synopsys translate_off
// synthesis translate_off
`ifndef SYNTHESIS

module tb_fpm_32bits;

  // ---------------- DUT ----------------
  logic [31:0] a, b, y;
  // Instantiate the Floating-Point Multiplier (fpm)
  fpm dut (.operand_a(a), .operand_b(b), .result(y));

  // -------------- Constants --------------
  localparam logic [31:0] QNAN    = 32'h7FC0_0000;
  localparam logic [31:0] PINF    = 32'h7F80_0000;
  localparam logic [31:0] NINF    = 32'hFF80_0000;
  localparam logic [31:0] PZERO   = 32'h0000_0000;
  localparam logic [31:0] NZERO   = 32'h8000_0000;
  localparam logic [31:0] MIN_SUB = 32'h0000_0001; // Smallest positive subnormal
  localparam logic [31:0] MAX_FIN = 32'h7F7F_FFFF; // Largest finite number

  // -------------- Helpers --------------
  // Checks if the given bit pattern represents a NaN (exponent is 0xFF and fraction is non-zero)
  function automatic bit is_nan (input logic [31:0] x);
    is_nan = (x[30:23] == 8'hFF) && (x[22:0] != 0);
  endfunction

  // Golden reference function for 32-bit floating-point multiplication (IEEE 754)
  function automatic logic [31:0] ref_mul32(input logic [31:0] aa, input logic [31:0] bb);
    logic        sa, sb;
    logic [7:0]  ea, eb;
    logic [22:0] fa, fb;
    bit          a_is_nan, b_is_nan, a_is_inf, b_is_inf, a_is_zero, b_is_zero;
    shortreal    ra, rb, rc;
    logic [31:0] rr;
    logic        result_sign;
    begin
      sa = aa[31]; sb = bb[31];
      ea = aa[30:23]; eb = bb[30:23];
      fa = aa[22:0];  fb = bb[22:0];

      result_sign = sa ^ sb; // Sign of multiplication is XOR of signs

      a_is_nan  = (ea==8'hFF) && (fa!=0);
      b_is_nan  = (eb==8'hFF) && (fb!=0);
      a_is_inf  = (ea==8'hFF) && (fa==0);
      b_is_inf  = (eb==8'hFF) && (fb==0);
      a_is_zero = (ea==8'h00) && (fa==0);
      b_is_zero = (eb==8'h00) && (fb==0);

      // Rule 1: NaN check
      if (a_is_nan || b_is_nan) return QNAN;

      // Rule 2: Inf * Zero check (Indeterminate Form) -> NaN
      if ((a_is_inf && b_is_zero) || (a_is_zero && b_is_inf)) return QNAN;

      // Rule 3: Inf check (Inf * anything non-zero/non-nan -> Inf)
      if (a_is_inf || b_is_inf) return {result_sign, 8'hFF, 23'h0};

      // Rule 4: Finite Calculation (Includes Normal * Normal, Subnormal, and Zero * Zero)
      ra = $bitstoshortreal(aa);
      rb = $bitstoshortreal(bb);
      rc = ra * rb; // *** PERFORM MULTIPLICATION ***
      rr = $shortrealtobits(rc);

      // Canonicalize any non-QNAN returned by the shortreal operation
      if (is_nan(rr)) rr = QNAN;
      return rr;
    end
  endfunction

  // -------------- Logging --------------
  integer fd_all, fd_fail;
  integer correct = 0, wrong = 0, total = 0;

  task automatic log_row(
    input integer fd,
    input int idx,
    input string tag,
    input logic [31:0] ta, tb, got, exp,
    input bit ok
  );
    logic        gs, es;
    logic [7:0] ge, ee;
    logic [22:0] gf, ef;
    begin
      gs = got[31]; ge = got[30:23]; gf = got[22:0];
      es = exp[31]; ee = exp[30:23]; ef = exp[22:0];
      // index,tag,a_hex,b_hex,got_hex,got_s,got_e_hex,got_f_hex,exp_hex,exp_s,exp_e_hex,exp_f_hex,verdict
      $fdisplay(fd, "%0d,%s,0x%08h,0x%08h,0x%08h,%0d,0x%02h,0x%06h,0x%08h,%0d,0x%02h,0x%06h,%s",
               idx, tag, ta, tb, got, gs, ge, gf, exp, es, ee, ef, (ok ? "PASS" : "FAIL"));
    end
  endtask

  // Task to apply inputs, wait, calculate golden result, compare, and log
  task automatic apply_and_record(input logic [31:0] ta, tb, input string tag);
    logic [31:0] exp;
    bit          ok;
    begin
      a = ta; b = tb;
      #1ns; // allow comb DUT to settle
      exp = ref_mul32(ta, tb); // *** USE MULTIPLICATION REFERENCE ***
      total++;
      ok = (y === exp); // Use === for 'X' or 'Z' comparison safety, though DUT should not output X/Z
      if (ok) correct++; else wrong++;
      log_row(fd_all,  total, tag, ta, tb, y, exp, ok);
      if (!ok) log_row(fd_fail, total, tag, ta, tb, y, exp, ok);
    end
  endtask

  // -------------- Directed special cases --------------
  typedef struct packed {logic [31:0] a, b;} pair_t;
  pair_t directed[$];

  // Helper functions for creating various NaNs
  function automatic logic [31:0] make_qnan(input logic sign, input logic [21:0] payload);
    make_qnan = {sign, 8'hFF, 1'b1, payload};
  endfunction
  function automatic logic [31:0] make_snan(input logic sign, input logic [21:0] payload);
    make_snan = {sign, 8'hFF, 1'b0, payload};
  endfunction

  // -------------- Main --------------
  initial begin
    int i;
    int N;
    int unsigned seed;
    logic [31:0] ra, rb;

    $timeformat(-9, 0, " ns", 8);

    // Open CSVs (Modified file names)
    fd_all  = $fopen("fpm_all.csv",  "w");
    fd_fail = $fopen("fpm_fail.csv", "w");
    if (fd_all == 0 || fd_fail == 0) $fatal(2, "Cannot open output CSV files.");

    // Headers
    $fdisplay(fd_all,  "index,tag,a_hex,b_hex,got_hex,got_s,got_e_hex,got_f_hex,exp_hex,exp_s,exp_e_hex,exp_f_hex,verdict");
    $fdisplay(fd_fail, "index,tag,a_hex,b_hex,got_hex,got_s,got_e_hex,got_f_hex,exp_hex,exp_s,exp_e_hex,exp_f_hex,verdict");

    // Build SPECIALS for MULTIPLICATION
    // ----------------------------------------------------
    // Inf * Inf -> Inf (Sign is XOR)
    directed.push_back('{PINF, PINF});    // +Inf * +Inf = +Inf
    directed.push_back('{PINF, NINF});    // +Inf * -Inf = -Inf
    directed.push_back('{NINF, NINF});    // -Inf * -Inf = +Inf

    // Inf * Finite -> Inf (Sign is XOR)
    directed.push_back('{PINF, 32'h4120_0000}); // +Inf * +10.0 = +Inf
    directed.push_back('{NINF, 32'hC120_0000}); // -Inf * -10.0 = +Inf
    directed.push_back('{32'h3F80_0000, NINF}); // +1.0 * -Inf = -Inf

    // Inf * Zero -> NaN (Indeterminate)
    directed.push_back('{PINF, PZERO});    // +Inf * +0 = NaN
    directed.push_back('{NINF, PZERO});    // -Inf * +0 = NaN
    directed.push_back('{PINF, NZERO});    // +Inf * -0 = NaN

    // Zero * Zero -> Zero (Sign is XOR)
    directed.push_back('{PZERO, PZERO});    // +0 * +0 = +0
    directed.push_back('{PZERO, NZERO});    // +0 * -0 = -0
    directed.push_back('{NZERO, NZERO});    // -0 * -0 = +0

    // Normal * Zero -> Zero (Sign is XOR)
    directed.push_back('{32'h4120_0000, PZERO}); // +10.0 * +0 = +0
    directed.push_back('{32'h4120_0000, NZERO}); // +10.0 * -0 = -0
    directed.push_back('{32'hC120_0000, NZERO}); // -10.0 * -0 = +0

    // Normal * Normal
    directed.push_back('{32'h3F800000, 32'h40000000}); // 1.0 * 2.0 = 2.0 (0x4000_0000)
    directed.push_back('{32'h40400000, 32'hC0400000}); // 3.0 * -3.0 = -9.0 (0xC110_0000)

    // Overflow / Underflow
    directed.push_back('{MAX_FIN, 32'h40000000}); // MAX_FIN * 2.0 -> Overflow to Inf
    directed.push_back('{MIN_SUB, MIN_SUB});     // Subnormal * Subnormal -> Underflow to Zero (or smaller subnormal)
    directed.push_back('{32'h0080_0000, 32'h0080_0000}); // Smallest normal * Smallest normal -> Subnormal

    // NaN Cases
    directed.push_back('{make_qnan(1'b0, 22'h123456), 32'h3F800000}); // qNaN * 1.0 -> NaN
    directed.push_back('{make_snan(1'b0, 22'h2), 32'h40000000});     // sNaN * 2.0 -> NaN
    directed.push_back('{32'h40400000, make_qnan(1'b0, 22'h3)});     // 3.0 * qNaN -> NaN

    // Run SPECIALS
    for (i = 0; i < directed.size(); i++) begin
      apply_and_record(directed[i].a, directed[i].b, $sformatf("dir[%0d]", i));
    end

    // Randoms
    N    = 1_000_000;    // change if needed
    seed = 32'hC0FF_EE01;
    void'($urandom(seed));    // seed ONCE

    for (i = 0; i < N; i++) begin
      ra = $urandom();
      rb = $urandom();
      apply_and_record(ra, rb, "rand");
      if ((i % 100000) == 0)
        $display("Progress: %0d / %0d (correct=%0d, wrong=%0d)", i, N, correct, wrong);
    end

    // Summary
    $display("------------------------------------------------------------");
    $display("Floating-Point Multiplier Test Summary:");
    $display(" Directed: %0d  Random: %0d  Total: %0d", directed.size(), N, total);
    $display(" Correct : %0d  Wrong : %0d", correct, wrong);

    $fclose(fd_all);
    $fclose(fd_fail);

    if (wrong == 0) begin
      $display("   ____   _    ____ ____     ");
      $display("  |  _ \\ / \\  / ___/ ___|    ");
      $display("  | |_) / _ \\ \\___ \\___ \\    ");
      $display("  |  __/ ___ \\ ___) |__) |   ");
      $display("  |_| /_/   \\_\\____/____/    ");
      $display("                             ");
      $display(" TEST PASSED: All results matched reference.");
      $finish;
    end else begin
      $display("       ____  _    ___ _      ");
      $display("      |  __|/ \\  |_ _| |     ");
      $display("      | |_ / _ \\  | || |     ");
      $display("      |  _/ ___ \\ | || |___  ");
      $display("      |_|/_/   \\_\\___|_____| ");
      $display("                             ");
      $fatal(1, " TEST FAILED: %0d mismatches out of %0d. See fpm_fail.csv", wrong, total);
    end
  end

endmodule

`endif
// synthesis translate_on
// synopsys translate_on
