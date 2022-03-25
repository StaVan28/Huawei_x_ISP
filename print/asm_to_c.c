#include <stdio.h>

extern "C" int my_printf (const char* str, ...);

const char* original   = "sral";
const char* hello_wrld = "hello, world!";

int main ()
{
    my_printf ("C: Vi vidite rozi? A ya na nih {%s}\n"
               "{b = [%b]}, {c = [%c]}, {d = [%d]}, {f = [%f]},\n"
               "{o = [%o]}, {x = [%x]}, {pr = [%%]}\n"
               "%d %s %x %d%%%c%b\n",
               hello_wrld, 28, '&', 28, 28, 28, 28, -1, "love", 3802, 100, '!', 15);

    //my_printf ("{%x}\n", 1 << 46);

    return 0;
}