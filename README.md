# x86_64 printf

This is a very simple implementation of printf in x86_64 intel assembly. This project uses yasm as a compiler.

The printf function has capabilities for '%s', '%c', and '%d'. There are no other formatting operations available.

## Algorithm

Algorithm displayed in `C` syntax.
```c
void printf(char* fmt, ...) {
  // the above line allocates 48 bytes on the stack using the stack pointer
  // we shall have 2 temporary variables that will also be allocated on the
  // stack
  int current_arg = 2, temp;
  while (*fmt) {
    if (*fmt == '%') {
      fmt++;
      switch (*fmt) {
        case '%':
          temp = '%' write(1, &temp, 1);
          break;
        case 'c':
          write(1, %rsp + current_arg * 8, 1);
          current_arg++;
          break case 's' : write(1, &tmp, strlen(%rsp + current_arg * 8));
          current_arg++;
          break;
        case 'd':
          // this one is more difficult
          // no allocations, but with register
          %num_digits = 0;
          %value = (%rsp + current_arg * 8);
          if (%value < 0) {
            temp = '-' write(1, &temp, 1);
          }
          do {
            %num_digits++;
            %tmp_value = %value;
            %value /= 10;
            push("9876543210123456789"[10 + (%tmp_value - %value * 10)]);  // push onto the stack
          } while (%value != 0)
              // we now have the stack looking like so (for the integer 12345):
              // %rsp -> [ '1', '2', '3', '4', '5', temp, arg4, arg3, arg2, arg1
              // ]
              write(1, %rsp,
                    %num_digits * 8);  // write using the stack pointer as
                                        // the starting address
          // the stack stores 32 bit values, so we will write 3 null bytes per
          // character
          %rsp -=
              %num_digits * 8;  // pop the string off the stack, so it is reset
          current_arg += 1;
      }
    } else {
      write(1, fmt, 1);  // write 1 character per pass
    }

    fmt++;
  }
}
```
