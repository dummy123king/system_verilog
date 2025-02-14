interface router_interface;
    logic reset;
    logic [7:0] dut_inp;
    logic inp_valid;
    logic [7:0] dut_outp;
    logic outp_valid;
    logic busy;
    logic [3:0] error;

    // Define modport for the testbench (TB)
    modport tb_modport (
        output reset, dut_inp, inp_valid,  // Signals driven by TB
        input outp_valid, dut_outp, busy, error  // Signals sampled by TB
    );

    // Define modport for the DUT
    modport dut_modport (
        input reset, dut_inp, inp_valid,  // Signals driven by TB
        output outp_valid, dut_outp, busy, error  // Signals sampled by TB
    );
endinterface


module top;
    // Section 1: Declare the clock
    logic clk;

    // Section 2: Clock initialization and generation
    initial clk = 0;
    always #5 clk = ~clk; // 10ns clock period

    // Section 4: Instantiate the interface
    router_interface intf();

    // Section 5: Instantiate the DUT and connect it to the interface
    router_dut dut_inst (
        .clk(clk),
        .reset(intf.reset),
        .dut_inp(intf.dut_inp),
        .inp_valid(intf.inp_valid),
        .dut_outp(intf.dut_outp),
        .outp_valid(intf.outp_valid),
        .busy(intf.busy),
        .error(intf.error)
    );

    // Section 6: Instantiate the testbench and connect it to the interface
    testbench tb_inst (
        .clk(clk),
        .router_if(intf.tb_modport)  // Connect the modport for the testbench
    );

    // Section 7: Dumping Waveform
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, top);
    end
endmodule