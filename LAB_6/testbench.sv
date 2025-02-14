program testbench(clk,reset,dut_inp,.....................);

//Section1: Declaration of input/output ports
input clk;
output reset;


//Section4: TB Variables declarations. 
//Variables required for various testbench related activities . 
//ex: stimulus generation,packing ....


bit [15:0] pkt_count;

//Section 6: Verification Flow
initial begin
pkt_count=10;


end

//Section 5: Methods (functions/tasks) definitions related to Verification Environment 

task apply_reset();
$display("[TB Reset] Applied reset to DUT at time=%0t",$time);    
reset<=1;
repeat(2) @(posedge clk);
reset<=0;
$display("[TB Reset] Reset Completed at time=%0t",$time);    
endtask




  
//Section 8: Collecting DUT output

  
endprogram

