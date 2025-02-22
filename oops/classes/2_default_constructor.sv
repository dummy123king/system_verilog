//------------------Constructor ----------------------------------
// In SystemVerilog, a constructor is a special method used to initialize
// an object of a class when it is created. It is explicitly defined to set up the initial state of the object, such as assigning values to member variables or allocating memory for dynamic data structures. Here's a breakdown of key points:
// 1. Constructor Basics 
// Name: The constructor is always named new in SystemVerilog.
// Invocation: Called automatically when an object is created using the new() method.
// Default Constructor: If no new method is defined, SystemVerilog implicitly provides a default constructor (which does nothing beyond memory allocation).

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
    pkt = new(); // Default constructor it allocates the memory and initializes to defalut values to variables
    pkt.print();
    $display("**********************************************************************");
    pkt.rd = 0;
    pkt.gen_write_stimulus();
    pkt.print();
  end
endprogram