//-------------------------------------Shallow copy --------------------------------------
// In SystemVerilog, a shallow copy creates a new object and copies all fields from the original object to the new one.
// However, if the original object contains references to other objects or dynamic data structures (e.g., dynamic arrays, queues, or class handles)
// the shallow copy will duplicate the references, not the underlying data.
// This means the copied object and the original will share the same referenced data. 
// When to Use Shallow Copy?
//  When you need a new object but want to share referenced data (e.g., for efficiency).
//  When modifying the copied object’s non-reference fields without affecting the original.


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
        
        // Modify properties of a1 and a2
        a1.m = 55; // Modify a1.m (does not affect a2.m)
        a2.m = 66; // Modify a2.m (does not affect a1.m)

        // Modify nested object through a1
        a1.nestedObj.x = 200; // Affects a2.nestedObj.x as well
      $display("a1.m = %0d\na1.k = %0d\na1.nestedObj = %d\n", a1.m, a1.k, a1.nestedObj.x);
      $display("a2.m = %0d\na2.k = %0d\na2.nestedObj = %d\n", a2.m, a2.k, a2.nestedObj.x);
    end
endprogram