class B;
    int x;
endclass

class A;
    int j, k;
    B b1; // Nested object
endclass

program test;
    A a1, a2;

    initial begin
        // Create object a1 and initialize its properties
        a1 = new;
        a1.j = 0;
        a1.k = 0;
        a1.b1 = new; // Create nested object
        a1.b1.x = 10;

        // Deep copy: Create a new object a2 and copy properties from a1
        a2 = new; // Create new object a2
        a2.j = a1.j; // Copy j from a1 to a2
        a2.k = a1.k; // Copy k from a1 to a2
        a2.b1 = new; // Create new nested object for a2
        a2.b1.x = a1.b1.x; // Copy x from a1.b1 to a2.b1

        // Modify properties of a1 and a2
        a1.j = 5; // Modify a1.j (does not affect a2.j)
        a2.j = 6; // Modify a2.j (does not affect a1.j)

        // Modify nested object through a1
        a1.b1.x = 20; // Does not affect a2.b1.x
    end
endprogram