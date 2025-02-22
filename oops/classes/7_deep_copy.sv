class B;
    int x;
endclass

class A;
    int j, k;
    B b1; // Nested object

    // Function to perform deep copy
    function A deep_copy();
        A copy = new; // Create a new instance of A
        copy.j = this.j; // Copy primitive properties
        copy.k = this.k;
        copy.b1 = new; // Create a new instance of B for the nested object
        copy.b1.x = this.b1.x; // Copy the nested object's properties
        return copy;
    endfunction
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

        // Perform deep copy of a1 to a2
        a2 = a1.deep_copy();

        // Modify properties of a1 and a2
        a1.j = 5; // Modify a1.j (does not affect a2.j)
        a2.j = 6; // Modify a2.j (does not affect a1.j)

        // Modify nested object through a1
        a1.b1.x = 20; // Does not affect a2.b1.x

        // Display values
        $display("a1.j = %0d\na1.k = %0d\na1.b1.x = %0d\n", a1.j, a1.k, a1.b1.x);
        $display("a2.j = %0d\na2.k = %0d\na2.b1.x = %0d\n", a2.j, a2.k, a2.b1.x);
    end
endprogram