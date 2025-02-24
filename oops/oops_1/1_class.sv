
// "Class" is a data type containing properties (variables) of various types,
// and methods (tasks and functions) for manipulating the data members.

class Packet;
  bit [7:0] addr;
  bit [7:0] wdata;
  logic rd, wr;
  function void print();
    $display("----------------------->>>addr = %0d", addr);
    $display("----------------------->>>wdata = %0d", wdata);
    $display("----------------------->>>rd = %0d", rd);
    $display("----------------------->>>wr = %0d", wr);
  endfunction
  
  task automatic gen_write_stimulus();
    wr = 1;
    addr = $urandom_range(1, 30);
    wdata = $urandom_range(20, 200);
  endtask

endclass

program test;
  Packet pkt;
  initial begin
    pkt = new();
    pkt.print();
    $display("**********************************************************************");
    pkt.rd = 0;
    pkt.gen_write_stimulus();
    pkt.print();
  end
endprogram