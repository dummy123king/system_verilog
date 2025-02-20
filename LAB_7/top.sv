
// Section 3: Define the interface
interface router_interface;
    logic reset;
    logic [7:0] dut_inp;
    logic inp_valid;
    logic [7:0] dut_outp;
    logic outp_valid;
    logic busy;
    logic [3:0] error;
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
        .router_if(intf)
    );

    // Section 7: Dumping Waveform
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, top);
    end

// Section 9: Error handling
    always @(intf.error) begin
        case (intf.error)
            1: $display("[TB Error] Protocol Violation. Packet driven while Router is busy");
            2: $display("[TB Error] Packet Dropped due to CRC mismatch");
            3: $display("[TB Error] Packet Dropped due to Minimum packet size mismatch");
            4: $display("[TB Error] Packet Dropped due to Maximum packet size mismatch");
            5: begin
                $display("[TB Error] Packet Corrupted. Packet dropped due to packet length mismatch");
                $display("[TB Error] Step 1: Check value of len field of packet driven from TB");
                $display("[TB Error] Step 2: Check total number of bytes received in DUT in the waveform (Check dut_inp)");
                $display("[TB Error] Check value of Step 1 matching with Step 2 or not");
            end
        endcase
    end


endmodule