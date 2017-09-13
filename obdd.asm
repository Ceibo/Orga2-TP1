extern free
extern malloc

global obdd_mgr_mk_node
obdd_mgr_mk_node:
ret

global obdd_node_destroy
obdd_node_destroy:
ret

global obdd_create
obdd_create:
ret

global obdd_destroy
obdd_destroy:
ret

global obdd_node_apply
obdd_node_apply:
ret

global is_tautology
is_tautology:
ret

global is_sat
is_sat:
ret

global str_len
str_len:

xor r12, r12; limpio r12d, ese va a ser el contador de 32 bits que voy a deovlver

.sumar:
cmp rdi, 0 ;si rdi es 0,
jz .terminar; si rdi es 0 termino. Como se si es cero o tiene un cero en el medio?
inc r12d; agrego uno al contador
add rdi, 1; agrego 1 byte al rdi, sigo recorriendo el string
jmp .sumar:

.terminar:
;add r12d, 1;
mov eax, r12d
ret

global str_copy
str_copy: ;tengo en RDI el string a copiar

call str_len ; llamo a esa funcion para tener el largo del string y saber hasta donde copiar
mov r10, rdi; me guardo el string de entrada para mandarlo despues a rax
mov rcx, rax; guardo el largo. Despues voy a decrementar de ahi
mov rdi, rax; Pongo el largo del string en rdi para que lo lea malloc
call malloc; Pido la memoria que voy a necesitar para copiar eso. Me devuelve en rax puntero al primero que quiero copiar
mov rax, r10; Aca pongo la entrada original, el puntero a primer elemento del string. Despues voy a copiar el resto
cmp ecx, 0x0; Me fijo si es un string vacio
je .terminar; Si el string es vacio voy directo al final

.copiarChar:
mov dl, [rdi + rcx]; pongo en dl(1 byte) el char que voy a copiar
mov [rax + rcx], dl; copio el char que corresponde.Hago estos dos mov para no pasar de memoria a memoria
loop .copiarChar; loop labura sobre el rcx

.terminar:
call free; libero la memoria
ret

global str_cmp
str_cmp:

call str_len; Calculo el largo de A, que estaba en RDI
mov edx, eax; Guardo en edx el largo de A
mov rcx, rdi; Guardo A en rcx por que voy a tener que usar ese registro
mov rdi, rsi; Pongo B en rdi, para llamar a str_len de B]
call str_len
mov r8d, eax; Pongo en r8d el largo de B
mov rdi, rcx; Vuelvo a la normalidad, pongo en rdi lo que tenia originalmente, A.
mov ecx, r8d; Ahora tengo en edx el largo de A y en ecx el largo de B.

cmp edx, ecx
jne .fin

;ahora voy a arrancar el ciclo, a comparar item por item si tienen el mismo largo
;loop toma de ecx, uso loop de una por que si llegue hasta el ciclo.

.comparacion:
cmp [rdi], [rsi] 
jne .noIguales; Si no son iguales los elementos termino el ciclo y mando a terminar. Ahora veo como lo hago
inc rdi; Si pasa y es que eran iguales aumento un byte en los dos y vuelvo al ciclo.
inc rsi
loop .comparacion

mov eax, 0;
jmp .return;

.noIguales:
cmp [rdi], [rsi]
ja .aMayor; jump above, por ser entero sin signo
jb .bMayor; jump below, por ser entero sin signo

.aMayor:
mov eax, -1
jmp .return

.bMayor
mov eax, 1
jmp .return

.return:
ret

