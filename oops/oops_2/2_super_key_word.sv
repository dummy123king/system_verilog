// The super keyword is used in a derived class 
// to refer to members of the base class. 
// This is particularly useful when the derived class has
//  members with the same names as those in the base class.


class Base;
    int a, b;
endclass

class Derived extends Base;
    int b, c;

    function print();
        a = 10;
      	b = 20;
      	super.b = 100;
      	c = 20;
      $display("\n\n------------------------>>>a = %0d, b = %0d, super.b = %0d, c = %0d", a, b, super.b, c);
    endfunction

endclass


program test;
    Derived d_obj;
    initial begin
        d_obj = new();
        d_obj.print();
    end
endprogram