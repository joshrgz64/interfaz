// ╔════════════════════════════════════════════════════════════════════════════╗
// ║  Programa : main.s                                                         ║
// ║  Autor    : Joshua Nezib Rodriguez Camarena - 24210524                     ║
// ║  Curso    : Lenguajes de Interfaz SCC-1014                                 ║
// ║  Fecha    : 10-22-2026                                                     ║
// ║  Descripción: Imprime un Hello world saludando con un nombre especifico    ║
// ╚════════════════════════════════════════════════════════════════════════════╝

        .section .data
msg:    .asciz  "Hola Joshua en ARM64\n"
len     =       . - msg - 1          // longitud sin el NUL

        .section .text
        .global _start

_start:
        // write(fd=1, buf=msg, count=len)
        mov     x8, #64              // syscall write (AArch64)
        mov     x0, #1               // stdout
        ldr     x1, =msg
        mov     x2, #len
        svc     #0

        // exit(0)
        mov     x8, #93              // syscall exit
        mov     x0, #0
        svc     #0

// Conclusiones/Observaciones:
// Cambie una sola linea para saludarme a mi mismo, forever alone
