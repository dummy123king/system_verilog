class B;
    int x;
endclass

class A;
    int m, k;
    B nestedObj; // Nested object
endclass

program test;
    A a1, a2;

    initial begin
        // Create object a1 and initialize its properties
        a1 = new;
        a1.m = 40;
        a1.k = 50;
        a1.nestedObj = new; // Create nested object
        a1.nestedObj.x = 100;

        // Shallow copy: Create a new object a2 and copy properties from a1
        a2 = new a1; // Shallow copy of a1 to a2
        a2.m = a1.m; // Copy m from a1 to a2
        a2.k = a1.k; // Copy k from a1 to a2
        a2.nestedObj = a1.nestedObj; // Copy reference to nested object

        // Modify properties of a1 and a2
        a1.m = 55; // Modify a1.m (does not affect a2.m)
        a2.m = 66; // Modify a2.m (does not affect a1.m)

        // Modify nested object through a1
        a1.nestedObj.x = 200; // Affects a2.nestedObj.x as well
      $display("a1.m = %0d\na1.k = %0d\na1.nestedObj = %d\n", a1.m, a1.k, a1.nestedObj.x);
      $display("a2.m = %0d\na2.k = %0d\na2.nestedObj = %d\n", a2.m, a2.k, a2.nestedObj.x);
    end
endprogram