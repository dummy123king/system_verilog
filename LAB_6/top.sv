//Section 7 : Interface definitioninterface


module top;

//Section1: Variables for Port Connections Of DUT and TB.
logic clk;

  
//Section2: Clock initiliazation and Generation
initial clk=0;
always #5 clk=!clk;

//Section 8 : Instantiate interface with instance name router_if_inst.


//Section3:  DUT instantiation
router_dut dut_inst(.clk(clk0,.reset(router_if_inst.reset),.......................);

//Section4:  Program Block (TB) instantiation
testbench  tb_inst(.clk(clk),.reset(router_if_inst.reset),......................);
 
//Section 6: Dumping Waveform
initial begin
  $dumpfile("dump.vcd");
  $dumpvars(0,top.dut_inst); 
end

endmodule