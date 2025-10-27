`timescale 1ps/1ps
module tb_mul32x32;

  // ==== I/O của DUT ====
  logic [31:0] a, b;
  logic [63:0] p;

  // ==== Instance DUT ====
  mul32x32 dut (
    .a(a),
    .b(b),
    .p(p)
  );

  // ==== Biến kiểm thử ====
  longint unsigned expected;  // 64-bit kết quả vàng
  int unsigned pass_cnt, fail_cnt;
  int unsigned i;
  int unsigned n_rand = 1_000_000;

  // ---- So sánh một trường hợp ----
  task automatic check_once(input logic [31:0] a_i,
                            input logic [31:0] b_i);
    begin
      a = a_i;
      b = b_i;
      #1; // chờ ổn định tổ hợp

      expected = a_i * b_i;
      if (p !== expected[63:0]) begin
        fail_cnt++;
        $error("FAIL: a=%h b=%h --> DUT p=%h, expected=%h",
               a, b, p, expected);
      end else begin
        pass_cnt++;
      end
    end
  endtask

  // ---- Trình tự kiểm thử ----
  initial begin
    pass_cnt = 0;
    fail_cnt = 0;

    // Các test có chủ đích
    check_once(32'h0,          32'h0);
    check_once(32'h1,          32'h0);
    check_once(32'h0,          32'h1);
    check_once(32'h1,          32'h1);
    check_once(32'hFFFF_FFFF,  32'h1);
    check_once(32'hFFFF_FFFF,  32'hFFFF_FFFF);
    check_once(32'h8000_0000,  32'h2);
    check_once(32'h1234_5678,  32'h9ABC_DEF0);

    // Random tests
    $display("[%0t] Bắt đầu random test %0d trường hợp", $time, n_rand);
    for (i = 0; i < n_rand; i++) begin
      check_once($urandom(), $urandom());
      if ((i % 100_000) == 0)
        $display("  progress: %0d / %0d", i, n_rand);
    end

    // Tổng kết
    if (fail_cnt == 0) begin
      $display("[%0t] ✅ PASS: %0d cases (FAIL=0)", $time, pass_cnt);
    end else begin
      $display("[%0t] ❌ FAIL: %0d fails / %0d passes", 
               $time, fail_cnt, pass_cnt);
    end

    $finish;
  end

endmodule
