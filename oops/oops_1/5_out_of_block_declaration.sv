class packet;
  bit [31:0] addr, data;

  extern function void print();          // Function prototype
  extern task run(input [31:0] m, output [31:0] y); // Task prototype
endclass

// Out-of-block method definitions using ::
function void packet::print();
  $display("[packet] addr=%0d data=%0d", addr, data);
endfunction

    task packet::run(input [31:0] m, output reg [31:0] y);
  y = m + 1;
endtask
    
    
module test;
  packet pkt = new();
  logic [31:0] result; // Declare outside the initial block

  initial begin
    pkt.addr = 10;
    pkt.data = 20;
    pkt.print();

    pkt.run(5, result); // Use the pre-declared variable
    $display("Result = %0d", result);
  end
endmodule