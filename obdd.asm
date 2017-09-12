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
ret
