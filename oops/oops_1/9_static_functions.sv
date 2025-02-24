// Static methods
// Method can be declared as static.
// Static method can be called outside the class, even with no class instantiation.
// A static method has no access to non-static members of class.
// But it can directly access static class properties or call static methods of the same class.
// Access to non-static members or to the special this handle within the body of a static method is illegal and results in a compiler error.
// Static methods cannot be virtual.

class Packet;
    bit [7:0] addr, data;
    int ret;
    static int id;

    function new();
        id++;
    endfunction

    static function int get();
        return id;
    endfunction
endclass

module test;
    initial begin
        Packet pkt1, pkt2;
        pkt1 = new;
        $display("static variable id=%0d", Packet::id);
        $display("static method ret=%0d", Packet::get());

        pkt2 = new;
        $display("static variable id=%0d", Packet::id);
        $display("static method ret=%0d", Packet::get());
    end
endmodule