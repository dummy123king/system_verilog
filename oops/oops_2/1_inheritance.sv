// Inheritance allows a class (derived class) to inherit properties and methods from another class (base class). 
// This promotes code reusability and hierarchical classification.

class Base;
    int b;
    function int get();
        return b;
    endfunction
endclass

class Derived extends Base;
    int c;
    function void print();
        $display("\n\n\nb = %0d c = %0d", b, c);
    endfunction
endclass


program test;
    Derived d_obj;
    Base b_obj;
    int b_ret, d_ret;
    initial begin
        b_obj = new(); // Base class 
        d_obj = new(); // Derived class
        
        b_obj.b = 40; 

        d_obj.b = 55;
        d_obj.c = 66;

        b_ret = b_obj.get(); // Base calss method

        d_ret = d_obj.get(); // Derived class accessing base class method

        d_obj.print(); // 

        $display("b_ret = %0d", b_ret);
        $display("d_ret = %0d", d_ret);
    end

endprogram