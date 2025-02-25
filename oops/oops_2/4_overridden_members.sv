

class Base;
    int k;
    function void print();
        $display("[Base] k = %0d", k);
    endfunction
endclass

class Derived extends Base;
    int m;
    function void print();
        $display("[Derived] m = %0d", m);
    endfunction
endclass


program test;
    Base b;
    Derived d;
    initial begin
        b =  new();
      	b.k = 55;
        b.print();
        
        d = new();
      	d.m = 88;
      	d.k = 99;
        d.print();
        // d = b; // it is illeagal
        
        b = d; // it is leagal
        b.print();
    end
endprogram