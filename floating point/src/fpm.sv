/*
==================================================================================================
  _____ _             _   _               ____       _       _     __  __       _ _   _       _       
 |  ___| | ___   __ _| |_(_)_ __   __ _  |  _ \ ___ (_)_ __ | |_  |  \/  |_   _| | |_(_)_ __ | |_   _ 
 | |_  | |/ _ \ / _` | __| | '_ \ / _` | | |_) / _ \| | '_ \| __| | |\/| | | | | | __| | '_ \| | | | |
 |  _| | | (_) | (_| | |_| | | | | (_| | |  __/ (_) | | | | | |_  | |  | | |_| | | |_| | |_) | | |_| |
 |_|   |_|\___/ \__,_|\__|_|_| |_|\__, | |_|   \___/|_|_| |_|\__| |_|  |_|\__,_|_|\__|_| .__/|_|\__, |
                                  |___/                                                |_|      |___/
==================================================================================================
*/
module fpm
(
   input  logic [31:0] operand_a,
   input  logic [31:0] operand_b,

   output logic [31:0] result
   );

   // ===========================================
   //         Unpacked operands
   // ===========================================

   logic        sign_a_in,  sign_b_in,  sign_result;
   logic [ 7:0] exp_a_in,   exp_b_in,   exp_result;
   logic [22:0] frac_a_in,  frac_b_in,  frac_result;

   logic        sign_a,     sign_b;
   logic [ 7:0] exp_a,      exp_b;
   logic [23:0] frac_a,     frac_b;

   assign {sign_a_in,  exp_a_in,   frac_a_in}  = operand_a;
   assign {sign_b_in,  exp_b_in,   frac_b_in}  = operand_b;  

   assign sign_a = sign_a_in;
   assign sign_b = sign_b_in;

   // ===========================================
   //          Wire / Logic 
   // ===========================================

   logic [23:0] round_frac_tmp;
   logic [22:0] pre_round_frac;   
   logic [23:0] frac_tmp;
   logic [23:0] temp_exp;
   logic [23:0] temp_exp1;
   logic [15:0] exp_sum, pre_exp_result;
   logic [63:0] pre_sel_frac;
   logic [31:0] normal_result;
   logic [15:0] ex_shift;
   logic        overflow;
   logic        overflow_to_inf;
   logic        underflow_to_subnor;

   // --- Logic for Normalization ---
   logic [5:0]  shift_amount;        // Output from LZC
   logic [63:0] normalized_product;  // Output from Shifter
   logic [15:0] normalized_exponent; // Adjusted exponent
   logic [15:0] corrected_normalized_exponent;
   logic        is_01_normal_case;

   // ===========================================
   //         Classification
   // ===========================================

   // Classification helpers
   logic a_is_zero,         b_is_zero;
   logic a_is_subnormal,    b_is_subnormal;
   logic a_is_inf,          b_is_inf;
   logic a_is_nan,          b_is_nan;
   logic Ea_is_zero,        Eb_is_zero;
   logic Ea_is_FF,          Eb_is_FF;
   logic Fa_is_zero,        Fb_is_zero;
   logic Fa_is_nzero,       Fb_is_nzero;
 
   classification   u_classification_fpm
   (
      .exp_a_in,        .exp_b_in,
      .frac_a_in,       .frac_b_in,

      .Ea_is_zero,      .Eb_is_zero,
      .Ea_is_FF,        .Eb_is_FF,
      .Fa_is_zero,      .Fb_is_zero,
      .Fa_is_nzero,     .Fb_is_nzero,

      .a_is_zero,       .b_is_zero,
      .a_is_subnormal,  .b_is_subnormal,
      .a_is_inf,        .b_is_inf,
      .a_is_nan,        .b_is_nan,

      .exp_a,           .exp_b,
      .frac_a,          .frac_b  
   );
 
   // ===========================================
   //         Sign Computation
   // ===========================================

   assign sign_result = sign_a_in ^ sign_b_in;

   // ===========================================
   //         Exponent Computation
   // ===========================================

   // 1. Add exponents
   adder_16bits   u_exponent
   (
      .operand_a ({8'b0, exp_a}),
      .operand_b ({8'b0, exp_b}),
      .cin       (1'b0),
      .sum       (exp_sum),
      .cout      ()
   );

   // 2. Subtract Bias
   subtractor_16bits   u_subtractor_16bits
   (
      .operand_a (exp_sum),
      .operand_b (16'd127),
      .diff      (pre_exp_result),
      .cout      ()
   );
 
   // 3. Subtract shift amount from LZC
   subtractor_16bits   u_exponent_normalized
   (
      .operand_a (pre_exp_result),
      .operand_b ({10'b0, shift_amount}), // Zero-extend LZC shift amount
      .diff      (normalized_exponent),
      .cout      ()
   );

   // 4. Add 1 for normalization
   // Case 1x.xxx: shift=0. temp_exp = (pre_exp - 0) + 1 = pre_exp + 1
   // Case 01.xxx: shift=1. temp_exp = (pre_exp - 1) + 1 = pre_exp
   // Case 00.1xx: shift=2. temp_exp = (pre_exp - 2) + 1 = pre_exp - 1
   adder_16bits      u_exponent_fix (
      .operand_a(normalized_exponent),
      .operand_b(16'd1),               // Add 1
      .cin      (1'b0),
      .sum      (temp_exp),            // Output is the new pre-rounding exponent
      .cout     ()
   );
 
    
   // 5. Add '1' if rounding caused fraction to overflow
   inc1       u_inc1_post_norm
   (
      .a     (temp_exp),
      .cin   (round_frac_tmp[23]), // Rounding increment

      .inc   (temp_exp1),
      .cout  ()  
   );  
    
   assign exp_result            =  temp_exp1[7:0];
   assign overflow_to_inf       =  ~temp_exp[9] & ( temp_exp[8] |  (&temp_exp[7:0]) );   // temp_exp >= 255
   assign underflow_to_subnor   = ( temp_exp[9] & temp_exp[8]) | (&(~temp_exp[7:0]));   // temp_exp <= 0
  
   // ===========================================
   //         Fraction Computation
   // ===========================================

   // 1. Multiply 24-bit fractions
   mult_32bits  u_mult_frac
   (
      .operand_a   ({8'b0, frac_a}),
      .operand_b   ({8'b0, frac_b}),
      .product     (pre_sel_frac) // 48-bit product
   );

   // Product is in pre_sel_frac[47:0]
   // '1x.xxxx...' -> overflow = 1
   // '01.xxxx...' -> overflow = 0
   // '00.1xxx...' -> overflow = 0
   assign overflow = pre_sel_frac[47];

   // 2. Find amount to shift (Leading Zero Count)
   lzc_48bits  u_lzc
   (
      .x  (pre_sel_frac[47:0]),   
      .q  (shift_amount)       // 6-bit shift amount
   );   

   // 3. Normalize fraction by shifting left
   shifter_64bits   u_shifter_norm
   (
      .A   (pre_sel_frac),       
      .B   (shift_amount),     // Shift by LZC amount
      .Sel (2'b10),            // << (Logical Left Shift)
      .Y   (normalized_product)   
   );    

   // 4. Select the 24-bit normalized fraction
   // The MSB (hidden bit) is at bit 47
   assign frac_tmp = normalized_product[47:24];

   // 5. Handle subnormal shifting
   nan_calculation   u_nan_calculation
   (
      .frac_tmp, 
      .temp_exp,
      .underflow_to_subnor,

      .pre_round_frac,
      .ex_shift
   ); 

   // 6. Calculate Round-to-Nearest-Even (RNE)
   RNE_fpm u_RNE
   (
      .normalized_product, // Use original un-shifted product for GRS bits
      .overflow,           // Pass overflow to select correct GRS bits
      .ex_shift,
      .underflow_to_subnor,

      .INC                 // Output: 1'b1 if increment is needed
   ); 

   // 7. Apply rounding increment
      inc1       u_inc1_norm
      (
      .a     ({1'b0,pre_round_frac}),
      .cin   (INC),

      .inc   (round_frac_tmp),
      .cout  ()  
   );  

   assign frac_result = round_frac_tmp[22:0];

   // ===========================================
   //     Result Selection with Special Cases
   // ===========================================

   assign normal_result = {sign_result, exp_result, frac_result};

   special_detect_fpm   u_special_detect_fpm
   (
      .a_is_zero,     .b_is_zero,
      .a_is_inf,      .b_is_inf,
      .a_is_nan,      .b_is_nan,
      .sign_a,        .sign_b,
      .sign_result,
      .operand_a,     .operand_b,     

      .normal_result,
      .overflow_to_inf,
      .underflow_to_subnor,
      .result  
   ); 

endmodule

/*
==================================================================================================
              ____                  _       _   ____       _            _   
             / ___| _ __   ___  ___(_) __ _| | |  _ \  ___| |_ ___  ___| |_ 
             \___ \| '_ \ / _ \/ __| |/ _` | | | | | |/ _ \ __/ _ \/ __| __|
              ___) | |_) |  __/ (__| | (_| | | | |_| |  __/ ||  __/ (__| |_ 
             |____/| .__/ \___|\___|_|\__,_|_| |____/ \___|\__\___|\___|\__|
                   |_|                                                      
==================================================================================================
*/

module special_detect_fpm
(
   input  logic            a_is_zero,  b_is_zero,
   input  logic            a_is_inf,   b_is_inf,
   input  logic            a_is_nan,   b_is_nan,
   input  logic            sign_a,     sign_b,
   input  logic            sign_result,
   input  logic            overflow_to_inf,
   input  logic            underflow_to_subnor,   
   
   input  logic   [31:0]   operand_a, operand_b,
   input  logic   [31:0]   normal_result,
   
   output logic   [31:0]   result   
);
   localparam logic [31:0] CANONICAL_QNAN = 32'h7FC0_0000;

   logic [31:0] special_result;
   logic        use_special;
   

   always_comb begin
      use_special    = 1'b0;
      special_result = 32'h0000_0000;
      
      // ===========================================
      //             Special by INPUT
      // ===========================================
      
      // NaN wins immediately
      if (a_is_nan || b_is_nan) begin
         use_special    = 1'b1;
         special_result = CANONICAL_QNAN;;
         
      // Indeterminate: 0 * Inf => NaN
      end else if ( (a_is_zero && b_is_inf) || (a_is_inf && b_is_zero) ) begin
         use_special    = 1'b1;
         special_result = CANONICAL_QNAN;
      
      // Signed zero: (signed)0 * (signed)0 => signed zero:
      end else if ( (operand_a[30:0] == 0) && (operand_b[30:0] == 0) ) begin
         use_special    = 1'b1;
         special_result = {sign_result, 31'b0};

      // Infinite: Inf * finite_nonzero => Inf (signed)
      end else if (a_is_inf && !b_is_inf && !b_is_zero) begin
         use_special    = 1'b1;
         special_result = {sign_result, 8'hFF, 23'b0};
      end else if (b_is_inf && !a_is_inf && !a_is_zero) begin
         use_special    = 1'b1;
         special_result = {sign_result, 8'hFF, 23'b0};
      end else if (b_is_inf && a_is_inf) begin
         use_special    = 1'b1;
         special_result = {sign_result, 8'hFF, 23'b0};

      // Zero: 0 * finite_nonzero => signed zero
      end else if (a_is_zero && !b_is_zero && !b_is_inf) begin
         use_special    = 1'b1;
         special_result = {sign_result, 31'b0};
      end else if (b_is_zero && !a_is_zero && !a_is_inf) begin
         use_special    = 1'b1;
         special_result = {sign_result, 31'b0};
         
      // Zero: 0 * 0 => signed zero
      end else if (a_is_zero && b_is_zero) begin
         use_special    = 1'b1;
         special_result = {sign_result, 31'b0};        
      
      // ===========================================
      //             Special by OUTPUT
      // ===========================================
      end else if (overflow_to_inf) begin
         use_special    = 1'b1;
         special_result = {sign_result, 8'hFF, 23'b0};
      end else if (underflow_to_subnor) begin
         use_special    = 1'b1;
         special_result = {sign_result, 8'h00, normal_result[22:0]};
      end      
   end 
 
   // ===========================================
   //             Select Result
   // ===========================================

   assign result = use_special ? special_result : normal_result;

endmodule 

/*
==================================================================================================
           _   _       _   _    ____      _            _       _   _             
          | \ | | __ _| \ | |  / ___|__ _| | ___ _   _| | __ _| |_(_) ___  _ __  
          |  \| |/ _` |  \| | | |   / _` | |/ __| | | | |/ _` | __| |/ _ \| '_ \ 
          | |\  | (_| | |\  | | |__| (_| | | (__| |_| | | (_| | |_| | (_) | | | |
          |_| \_|\__,_|_| \_|  \____\__,_|_|\___|\__,_|_|\__,_|\__|_|\___/|_| |_|
                                                                                 
==================================================================================================
*/

module nan_calculation
(
   input  logic [23:0]  frac_tmp, 
   input  logic [23:0]  temp_exp,
   input  logic         underflow_to_subnor,
       
   output logic [22:0]  pre_round_frac,
   output logic [15:0]  ex_shift
);

   logic [ 4:0] shift;
   logic [31:0] frac_nan; 
   logic        tmp0;
    
    // Calculate amount of extra shift to reach Efield==0
    // ex_shift = 1 - exponent after normalization 
    //          = 1 + (~result_exp_1[7:0]) + 1
   
    adder_16bits     extra_shift
   (
       .operand_a (16'h01),
       .operand_b (~temp_exp[15:0]),
       .cin       (1'b1),

       .sum       (ex_shift),
       .cout      ()
   );
 
   assign tmp0 = (ex_shift[7] | ex_shift[6] | ex_shift[5]) | (ex_shift[4] & ex_shift[3]);
   
   always @(*) begin
      if (tmp0) begin
         shift = 5'b11111;
      end else begin 
         shift = ex_shift[4:0];
      end
   end

   shifter_32bits    denorm_shift
   (
      .A    ({9'b0,frac_tmp}),  
      .B    (shift),  

      .Sel  (2'b00),		// >>
      .Y    (frac_nan)
   );
   
   always @(*) begin
      if (underflow_to_subnor) begin
         pre_round_frac = frac_nan[22:0];
      end else begin 
         pre_round_frac = frac_tmp[22:0];
      end
   end

endmodule

/*
==================================================================================================
        ____                       _   _          _   _                          _   
       |  _ \ ___  _   _ _ __   __| | | |_ ___   | \ | | ___  __ _ _ __ ___  ___| |_ 
       | |_) / _ \| | | | '_ \ / _` | | __/ _ \  |  \| |/ _ \/ _` | '__/ _ \/ __| __|
       |  _ < (_) | |_| | | | | (_| | | || (_) | | |\  |  __/ (_| | | |  __/\__ \ |_ 
       |_| \_\___/ \__,_|_| |_|\__,_|  \__\___/  |_| \_|\___|\__,_|_|  \___||___/\__|
                                                                                     
==================================================================================================
*/
module RNE_fpm
(
   // INPUTS
   input  logic   [63:0]  normalized_product, // <-- Use the normalized product
   input  logic   [15:0]  ex_shift,
   input  logic           underflow_to_subnor,

   // This input is ignored, but kept for port matching
   input  logic           overflow, 

   // OUTPUT
   output logic           INC
);

   // GRS bits are relative to the normalized fraction
   // normalized_product[47]    = Hidden Bit (1)
   // normalized_product[46:24] = 23-bit Fraction
   // normalized_product[24]    = LSB (Least Significant Bit)
   // normalized_product[23]    = G (Guard Bit)
   // normalized_product[22]    = R (Round Bit)
   // normalized_product[21:0]  = S (Sticky Bits)

   logic G, R, S;    // Guard/Round/Sticky
   logic LSB;        // Least Significant Bit

   logic        tmp0;
   logic [5:0]  shift;
   logic [63:0] denorm_frac; // For subnormal rounding
 
   // Check for large shifts (saturate to 63)
   assign tmp0 = (ex_shift[7] | ex_shift[6]) | (ex_shift[5] & ex_shift[4]);
 
   always @(*) begin
      if (tmp0) begin
         shift = 6'b111111; // Saturate shift
      end else begin 
         shift = ex_shift[5:0];
      end
   end
 
   // Denormalize the fraction for subnormal rounding
   shifter_64bits   u_nan_rne
   (
       .A   (normalized_product), // Start with normalized frac 
       .B   (shift),              // Shift right by (1 - exponent)
       .Sel (2'b00),              // >>
       .Y   (denorm_frac)         
   );  

   always @(*) begin
      if (underflow_to_subnor) begin
         // Use denormalized fraction for GRS
         G     =  denorm_frac[23];
         R     =  denorm_frac[22];
         S     = |denorm_frac[21:0];
         LSB   =  denorm_frac[24]; 
      end 
      else begin 
         // Use NORMALIZED fraction for GRS
         G     =  normalized_product[23];
         R     =  normalized_product[22];
         S     = |normalized_product[21:0];
         LSB   =  normalized_product[24];
      end
   end     
         
   // RNE logic: Increment if G=1 AND (R=1 or S=1 or LSB=1)
   assign INC = G & ( R | S | LSB );
 
endmodule


///*
//==================================================================================================
//                  ____ _               _  __ _           _   _             
//                 / ___| | __ _ ___ ___(_)/ _(_) ___ __ _| |_(_) ___  _ __  
//                | |   | |/ _` / __/ __| | |_| |/ __/ _` | __| |/ _ \| '_ \ 
//                | |___| | (_| \__ \__ \ |  _| | (_| (_| | |_| | (_) | | | |
//                 \____|_|\__,_|___/___/_|_| |_|\___\__,_|\__|_|\___/|_| |_|
//                                                                           
//==================================================================================================
//*/
//module classification
//(
//    input  [7:0]  exp_a_in, exp_b_in,
//    input  [22:0] frac_a_in, frac_b_in,
//
//    output logic  a_is_zero, b_is_zero,
//    output logic  a_is_subnormal, b_is_subnormal,
//    output logic  a_is_inf, b_is_inf,
//    output logic  a_is_nan, b_is_nan,
//
//    output logic  Ea_is_zero, Eb_is_zero,
//    output logic  Ea_is_FF,   Eb_is_FF,
//    output logic  Fa_is_zero, Fb_is_zero,
//    output logic  Fa_is_nzero,Fb_is_nzero,
//    
//    output logic  [7:0]    exp_a, exp_b,
//    output logic  [23:0]   frac_a, frac_b
//);
//
//    //==============================
//    //  Exponent conditions
//    //==============================
//    // Ea_is_zero = all bits 0
//    // Ea_is_FF   = all bits 1
//    assign Ea_is_zero = ~(|exp_a_in);
//    assign Eb_is_zero = ~(|exp_b_in);
//    assign Ea_is_FF   = &exp_a_in;
//    assign Eb_is_FF   = &exp_b_in;
//
//    //==============================
//    //  Fraction conditions
//    //==============================
//    assign Fa_is_zero  = ~(|frac_a_in);
//    assign Fb_is_zero  = ~(|frac_b_in);
//    assign Fa_is_nzero = |frac_a_in;    
//    assign Fb_is_nzero = |frac_b_in;
//
//    //==============================
//    //  IEEE-754 Class Detection
//    //==============================
//    // ZERO: exp=0 & frac=0
//    // SUBNORMAL: exp=0 & frac!=0
//    // INF: exp=FF & frac=0
//    // NAN: exp=FF & frac!=0
//
//    assign a_is_zero      = Ea_is_zero & Fa_is_zero;
//    assign b_is_zero      = Eb_is_zero & Fb_is_zero;
//
//    assign a_is_subnormal = Ea_is_zero & Fa_is_nzero;
//    assign b_is_subnormal = Eb_is_zero & Fb_is_nzero;
//
//    assign a_is_inf       = Ea_is_FF & Fa_is_zero;
//    assign b_is_inf       = Eb_is_FF & Fb_is_zero;
//
//    assign a_is_nan       = Ea_is_FF & Fa_is_nzero;
//    assign b_is_nan       = Eb_is_FF & Fb_is_nzero;
//    
//   // Hidden bit: 1 for normals, 0 for zero/subnormals/NaN/Inf (only used for add path)
//   logic hidden_a;
//   logic hidden_b;
//    
//   always_comb begin
//      hidden_a =  1'b0;
//      hidden_b =  1'b0;
//      exp_a       =  exp_a_in;
//      exp_b       =  exp_b_in;
//      
//      // effective exponent for subnormals = 1 (for operations)
//      if (Ea_is_zero) exp_a = 8'd1;
//      if (Eb_is_zero) exp_b = 8'd1;
//
//      // hidden bit = 1 only for normals
//      if (!Ea_is_zero && !Ea_is_FF) hidden_a = 1'b1;
//      if (!Eb_is_zero && !Eb_is_FF) hidden_b = 1'b1;     
//   end
//   
//   assign frac_a = {hidden_a, frac_a_in};
//   assign frac_b = {hidden_b, frac_b_in};
//   
//endmodule

/*
==================================================================================================
        ____                                    __  __           _       _      
       |  _ \ _   _ _ __ ___  _ __ ___  _   _  |  \/  | ___   __| |_   _| | ___ 
       | | | | | | | '_ ` _ \| '_ ` _ \| | | | | |\/| |/ _ \ / _` | | | | |/ _ \
       | |_| | |_| | | | | | | | | | | | |_| | | |  | | (_) | (_| | |_| | |  __/
       |____/ \__,_|_| |_| |_|_| |_| |_|\__, | |_|  |_|\___/ \__,_|\__,_|_|\___|
                                        |___/                                   
==================================================================================================
*/



module adder_8bits 
(
    input logic [7:0] operand_a,
    input logic [7:0] operand_b,
    input logic        cin,

    output logic [7:0] sum,
    output logic        cout
);
    assign {cout, sum} = operand_a + operand_b + cin;

endmodule



module adder_16bits 
(
    input logic [15:0] operand_a,
    input logic [15:0] operand_b,
    input logic        cin,

    output logic [15:0] sum,
    output logic        cout
);
    assign {cout, sum} = operand_a + operand_b + cin;

endmodule



module subtractor_16bits 
(
    input logic [15:0] operand_a,
    input logic [15:0] operand_b,

    output logic [15:0] diff,
    output logic        cout
);

    // A - B = A + (~B) + 1
    adder_16bits u_add (
        .operand_a (operand_a),
        .operand_b (~operand_b),
        .cin       (1'b1),
        .sum       (diff),
        .cout      (cout)
    );
    
endmodule



module adder_32bits 
(
    input logic [31:0] operand_a,
    input logic [31:0] operand_b,
    input logic        cin,

    output logic [31:0] sum,
    output logic        cout
);
    assign {cout, sum} = operand_a + operand_b + cin;

endmodule


module adder_64bits 
(
    input logic [63:0] operand_a,
    input logic [63:0] operand_b,
    input logic        cin,

    output logic [63:0] sum,
    output logic        cout
);
    assign {cout, sum} = operand_a + operand_b + cin;

endmodule 


module mult_32bits 
(
    input  logic [31:0] operand_a,
    input  logic [31:0] operand_b,

    output logic [63:0] product
);
    assign product = operand_a * operand_b;

endmodule 


