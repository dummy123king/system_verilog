module top;

    // Section 1: Variables for Port Connections Of DUT and TB
    reg clk;
    logic reset;
    logic [7:0] dut_inp;
    logic inp_valid;
    logic [7:0] dut_outp;
    logic outp_valid;
    logic busy;
    logic [3:0] error;

    // Section 2: Clock Initialization and Generation
    initial clk = 0;
    always #5 clk = ~clk; // 10ns clock period

    // Section 3: DUT Instantiation
    router_dut dut_inst (
        .clk(clk),
        .reset(reset),
        .dut_inp(dut_inp),
        .inp_valid(inp_valid),
        .dut_outp(dut_outp),
        .outp_valid(outp_valid),
        .busy(busy),
        .error(error)
    );

    // Section 4: Testbench Instantiation
    testbench tb_inst (
        .clk(clk), // Now correctly passed as input
        .reset(reset),
        .dut_inp(dut_inp),
        .inp_valid(inp_valid),
        .dut_outp(dut_outp),
        .outp_valid(outp_valid),
        .busy(busy),
        .error(error)
    );

    // Section 5: Dumping Waveform
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, top);
    end

endmodule
