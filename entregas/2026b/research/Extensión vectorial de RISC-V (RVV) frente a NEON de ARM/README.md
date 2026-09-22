# Extensión vectorial de RISC-V (RVV) frente a NEON de ARM
## Introducción
Las arquitecturas que constituyen a los procesadores cumplen múltiples funciones que la mayoría de gente pasa por alto, es que son necesarias para formar las reglas y métodos que una computadora utilizará para almacenar información, mostrar imágenes en una pantalla e interactuar con el usuario; desde sus inicios más primitivos con tarjetas perforadas hasta la actualidad que han llegado a avances como la ejecución de LLMs, los procesadores han logrado esto gracias a sus complejas arquitecturas que les dan forma.
## Desarrollo Técnico
### RISC-V
Es una arquitectura relativamente reciente (lanzada en 2014) cuyas siglas en inglés significan "Computadora por Conjunto de Instrucciones Reducidas", esto significa que Risc-V es una arquitectura de procesadores que gestiona los bits de memoria a partir de pocas instrucciones que van directo a la memoria. Es una ISA, una Arquitectura de Conjunto de Instrucciones, lo cual es una interfaz abstracta entre el procesador y el software que corre que define las instrucciones de memoria, tipos de datos, registros, modelos de acceso a memoria, y el manejo de entrada y salida.\
Risc-V es de código abierto. Opera tanto en espacios de direcciones de 32 bits como de 64 bits, y tiene soporte para su  implementación en procesadores multicore (2 - 16 nucleos) o manycore (hasta miles de nucleos simples).\
La V en Risc-V significa que es la 5ta generación de arquitecturas RISC ISA por la Universidad de Berkeley, la V también significa "Vectorial" y "Variaciones",  los enfoques principales de esta arquitectura como veremos más adelantes.
#### Extensión Vectorial RVV
Como su nombre lo indica, Risc-V Vectorial Extension es una extensión de la ISA de Risc-V con el propósito de añadir soporte para operaciones vectoriales. Con vectores nos referimos a conjuntos dinámicos de datos (arrays) con elementos del mismo tipo que pueden ser manipulados con gran facilidad a diferencia de los arrays tradicionales. Estas operaciones complementan las que el ISA base ejecuta para la gestión de memoria. Algunas de sus funciones incluyen el registro de vectores, la operación con vectores, su configuración, trabajar con "mascaras", y las operaciones de carga y almacenamiento.\
RVV maneja dos variables clave,\
Una es denominada **ELEN**, longitud del elemento, es el tamaño máximo de un elemento que una implementación podrá soportar, debe ser una potencia de 2.\
denominado **VLEN** el cual representa la longitud del registro de un solo vector en bits, utilizado en lugar de un valor constante. VLEN tiene que ser una potencia de 2 que no supere los $2^{16}$ bits y además debe ser mayor o igual a ELEN.\
RVV maneja 32 registros vectoriales desde **v0 hasta v31**. El valor VLEN es bastante flexible, por lo que para implementaciones diferentes este valor puede ser cambiado permitiendo abarcar más información en menos registros, por ejemplo:

```
VLEN = 128
v0 = 128
v1 = 128
v2 = 128
v3 = 128
```

```
VLEN = 256
v0 = 256
v1 = 256
```

**SEW**, el ancho del elemento elegido define con cuántos elementos dentro de un vector se puede trabajar a partir de su VLEN.\
Digamos que tenemos un VLEN de 128 bits y queremos trabajar con 32 bits cada elemento, para eso SEW será igual a 32 bits.
```
VLEN = 128 bits
SEW = 32 bits
VLEN / SEW = 4 elementos
```
Por lo tanto, cada elemento denominado a0 - a3 tendrá un valor de 32 bits, esto facilita el trabajo con múltiples datos al dividirlos en partes, especialmente si se trabaja con el máximo de $2^{16}$.\
**VL** nos dice con cuántos elementos se trabajará a la vez una vez definida la cantidad de estos, por ejemplo tenemos 4 elementos totales, digamos que VL es igual a 2, entonces de esos vectores se trabajará con 2 elementos a la vez.

**LMUL** es un multiplicador que permite agrupar múltiples registros vectoriales para unirlos en un nuevo grupo de registros y apoyar en el pase de más elementos. Su valor puede ser 1/8, 1/4, 1/2, 1, 2, 4, o 8; uno de ellos corresponderá al tamaño del grupo. Entonces volviendo al ejemplo anterior, si tuviéramos un LMUL de 4...
```
VLEN = 128 bits
SEW = 32 bits
LMUL = 4
4 elementos * LMUL = 16 elementos de 32 bits
```
LMUL permite que el procesador trabaje con más elementos por medio de grupos multiplicados.\
Seguimos con **VLMAX**, el cual nos dice finalmente cuál es el valor máximo de elementos que se pueden manejar con la configuración definida hasta ahora por grupo. Su valor es igual a el producto de VLEN y LMUL sobre SEW, ósea...

$VLMAX=\frac{VLEN \cdot LMUL}{SEW}$

Por lo que  si tomamos los valores actuales...
```
VLEN = 128 bits
LMUL = 4
SEW = 32 bits
VLMAX = (128 * 4)/32 = 16
```
VLMAX aquí es igual a 16, lo que significa que el procesador con la configuración actual puede controlar hasta 16 elementos por operación.

Crear código para la manipulación de múltiples elementos puede parecer tedioso si asumimos que se tendría que hacer esto para cada uno de ellos individualmente, es por esto que existe una técnica llamada stripmining, la misma consiste en iterar instrucciones de manera que el procesador pueda procesar grandes cantidades de datos de forma eficiente, se crean bloques en base al valor de VLMAX, por ejemplo cada bloque procesará 16 elementos por iteración.\
Veámoslo de esta manera, supongamos que tenemos 100 elementos y queremos procesarlos todos, como podemos procesarlos todos sin tener que llamar la operación 100 veces? stripmining como técnica resuelve esto de manera que si nuestro VLMAX es 16, entonces el bloque iterativo procesará 16 elementos por iteración.

Ah, pero si contamos bien...
```
iter 1 --> elems 0 - 15
iter 2 --> elems 16 - 31
...
iter 6 --> elems 80 - 95
```
Quedan 4 elementos sin procesar, acaso se pueden procesar aun asi? Claro que si, si el VL que son los elementos  que se pueden procesar a la vez era 16, a partir de este punto VL pasa a ser igual a 4, esto permite terminar de procesar los elementos que faltan.
```
iter 7 --> elems 96 - 99
```
Para cerrar con RVV veamos un ejemplo practico de su uso. Digamos que en su lugar contamos con un total de 20 elementos, queremos hacer una cierta prueba de rendimiento, pero cómo? Ahí es donde entra una función útil en las pruebas de rendimiento.
```assembly
# void saxpy(size_t n, float a, const float *x, float *y)
# a0 = n, fa0 = a, a1 = x, a2 = y
loop:
    vsetvli  t0, a0, e32, m2, ta, ma   # t0 = elements this pass

    vle32.v  v0, (a1)                  # load x[i..i+vl]

    sub      a0, a0, t0                # n -= vl

    slli     t1, t0, 2                 # bytes = vl * 4

    add      a1, a1, t1                # x += vl

    vle32.v  v8, (a2)                  # load y[i..i+vl]
    vfmacc.vf v8, fa0, v0             # y = a*x + y (fused multiply-add)
    vse32.v  v8, (a2)                  # store y back

    add      a2, a2, t1                # y += vl
    bnez     a0, .loop                 # repeat until done
```
¿Qué significa esta función?\
Lo que ves es una función SAXPY (Single-expression A times X Plus Y), una función fundamental en la prueba de CPUs y GPUs con cualidades vectoriales la cual efectúa la ecuación $y = a \cdot x + y$.
Para recordar bien los parámetros tienes que saber que para este nuevo ejemplo:
```
a0 = 20 (elementos restantes, hasta ahora no se ha procesado ninguno)
e32 = SEW = 32
m2 = LMUL = 1
t0 es donde los resultados se almacenarán
```
la instrucción `vsetvli t0, a0, e32, m2, ta, ma` pide al CPU procesar la cantidad necesaria que indique `a0`, estos elementos son de 32 bits y su LMUL es de 2, y el resultado de la operación será guardado en `t0`.
Digamos que nuestro `VLMAX = 8`, y sabemos que tenemos 20 elementos. RVV por medio de vsetvli obtiene un VL en base a los parámetros ingresados. Entonces con esto nos daría un valor de `t0 = 8`.

`vle32.v v0, (a1)` es una instrucción que carga elementos de 32 bits hacia los registros vectoriales.\
Después `sub a0, a0, t0` lo que hace es restar `a0` con `t0` y guardar el resultado devuelta en `a0`. La operación sería `20 - 8` pues `a0 = 20` y `t0 = 8`. Entonces ahora `a0 = 12`\
`slli t1, t0, 2` nos dice una sola cosa, primero que nada 32 bits es equivalente a 4 bytes, entonces con esta instrucción se define con cuantos bytes se trabajará, `8 elementos * 4 bytes = 32 bytes`\
`add a1, a1, t1` indica que el puntero 1 avanza hacia delante.\
Ahora entramos a la parte importante
```
vle32.v  v8, (a2)
vfmacc.vf v8, fa0, v0
vse32.v  v8, (a2)
```
Primero cargamos los elementos hacia un registro 8, en seguida de esto sigue la instrucción `vfmacc.vf` hace la operación SAXPY, tomando el registro `v8` donde se almacenará el resultado, `fa0` es un punto flotante, y `v0` es el registro inicial.
Cuando el resultado haya sido guardado en el registro v8, entonces se vuelve a almacenar en la memoria.
```
add a2, a2, t1
bnez a0, loop
```
Se incrementa el contador a2, una vez hecho esto llegamos a la instrucción de loop, por lo que empezamos de nuevo, y así hasta que se hallan procesado todos los 20 elementos.

### Arm NEON
Neon es una implementación de la extensión para arquitecturas de CPUs Arm la cual trabaja con instrucciones SIMD avanzadas, las cuales trabajan con datos en 64 o 128 bits. Diseñado para mejorar el rendimiento en el procesamiento de datos multimedia, entre ellos no limitado a: codificación y decodificación de video y audio, procesamiento de gráficos 3D, voz e imagenes.

#### Modelo SIMD
**SIMD** significa que con una sola instrucción se pueden procesar tipos de datos diferentes (Single Instruction Multiple Data), por ejemplo con una sola instrucción la misma puede trabajar tanto con imágenes como con video, o con audio, todo de forma paralela.\
Visto de otra manera, SIMD permite que en vez de hacer digamos, 7 operaciones de forma separada entre valores de dos arreglos, con una sola instrucción se hagan las 7 operaciones de manera paralela.

## Conclusión

## Bibliografía 
* Arm. “What is Instruction Set Architecture (ISA)?” Arm. Accedido el 22 de septiembre de 2026. [En línea]. Disponible: https://www.arm.com/glossary/isa
* DigiKey. “Introducción a RISC-V”. DigiKey. Accedido el 22 de septiembre de 2026. [En línea]. Disponible: https://www.digikey.com.mx/es/resources/risc-v
* Risc-V. “Introduction”. RISC-V Ratified Specifications Library. Accedido el 22 de septiembre de 2026. [En línea]. Disponible: https://docs.riscv.org/reference/isa/v20260120/unpriv/intro.html
* L. Berton. “RISC-V Vector Programming with RVV 1.0”. Luca Berton. Accedido el 22 de septiembre de 2026. [En línea]. Disponible: https://lucaberton.com/blog/risc-v-vector-extension-rvv-programming/
* “Overview”. Arm Support. Accedido el 22 de septiembre de 2026. [En línea]. Disponible: https://support.arm.com/documentation/102159/0400/Overview
* https://developer.mozilla.org/es/docs/Glossary/SIMD
* 
