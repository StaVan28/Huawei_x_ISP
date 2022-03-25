#include <stdio.h>

extern "C" int my_printf (const char* str, ...);

const char* original   = "sral";
const char* hello_wrld = "hello, world!";

int main ()
{
//     my_printf ("C: Vi vidite rozi? A ya na nih {%s}\n"
//                "{b = [%b]}, {c = [%c]}, {d = [%d]}, {f = [%f]},\n"
//                "{o = [%o]}, {x = [%x]}, {pr = [%%]}\n"
//                "%d %s %x %d%%%c%b\n",
//                hello_wrld, 28, '&', '&', 28, 28, 28, -1, "love", 3802, 100, '!', 15);

    for (int i = 0; i < 1 << 22; i++)
    {    
        my_printf ("C: Vi vidite rozi? A ya na nih {%s}\n"
                   ", {c = [%c]}, {d = [%d]}, ,\n"
                   "{o = [%o]}, {x = [%x]}, {pr = [%%]}\n"
                   "%d %s %x %d%%%c\n",
                   hello_wrld, '&', '&', 28, 28, -1, "love", 3802, 100, '!');
    }

    return 0;
}