class Packet;
    static int id;       // Static variable shared across all instances
    bit [7:0] obj_id;    // Instance-specific variable

    function new();
        id++;            // Increment the static variable
        obj_id = id;     // Assign the current value of id to obj_id
    endfunction
endclass

module test;
    Packet pkt1, pkt2, pkt3;

    initial begin
        // Display initial value of static id (before any objects are created)
        $display("Initial id = %0d", pkt1.id); // Access static variable through an instance

        // Create objects and display the id after each creation
      	pkt1 = new(); 
        $display("After creating pkt1: id = %0d, pkt1.obj_id = %0d", pkt1.id, pkt1.obj_id);

      	pkt2 = new(); 
        $display("After creating pkt2: id = %0d, pkt2.obj_id = %0d", pkt2.id, pkt2.obj_id);

      	pkt3 = new(); 
        $display("After creating pkt3: id = %0d, pkt3.obj_id = %0d", pkt3.id, pkt3.obj_id);

        // Display the final state of all objects
        $display("Final state:");
        $display("pkt1.obj_id = %0d", pkt1.obj_id);
        $display("pkt2.obj_id = %0d", pkt2.obj_id);
        $display("pkt3.obj_id = %0d", pkt3.obj_id);
      $display("Static id = %0d", Packet::id); // Access static variable through an instance
    end
endmodule