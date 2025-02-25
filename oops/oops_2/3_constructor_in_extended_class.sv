class Base;
    int m;
    function new(int f);
        m = f;
    endfunction
endclass

class Derived extends Base;
    int k;
    function new(int d);
        super.new(d);
    endfunction
endclass


program test;
    Derived d;
    initial begin
        d = new(55);
      	d.k = 85;
      	$display("------------->>k = %0d", d.k);
      	$display("------------->>m = %0d", d.m);
    end
endprogram