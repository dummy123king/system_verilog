class A;
  int data;
endclass

class B;
  int data;
  A a_obj;
endclass

program test;
  initial begin
    B obj = new(); // Allocating memory to "Class B" objetct and initializing variable to its default values
    obj.a_obj = new(); // Allocating memory to "Class A" objetct and initializing variable to its default values
    obj.data = 55;
    obj.a_obj.data = 88;
    $display("\n\n----------------------------->>>>obj.data = %0d and obj.a_obj.data = %0d\n\n", obj.data, obj.a_obj.data);
  end
endprogram