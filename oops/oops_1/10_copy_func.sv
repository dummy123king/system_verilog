class A;
    int data, addr;

    function void copy(A a);
        this.data = a.data;
        this.addr = a.addr;        
    endfunction

endclass

program test;
    A a1, a2;
    initial begin
        a1 = new();
        a1.addr = 4444;
        a1.data = 55;

        a2 = new();
      	a2.copy(a1);

        // Display values
        $display("a1: addr = %0d, data = %0d", a1.addr, a1.data);
        $display("a2: addr = %0d, data = %0d", a2.addr, a2.data);
    end
endprogram