section .rodata
%define NULL 0
%define obdd_manager_size
%define obdd_root_size

%define obdd_node_var_ID_offset 0
%define obdd_node_node_ID_offset 4
%define obdd_node_ref_count_offset 8
%define obdd_node_high_offset 12
%define obdd_node_low_offset 20
%define obdd_node_size 28;3 uint32 y 2 punteros. 224 bits

%define mgr_ID_offset 0
%define mgr_greatest_node_ID_offset 4
%define mgr_greatest_var_ID_offset 8
%define mgr_true_obdd_offset 12
%define mgr_false_obdd_offset 20
%define mgr_vars_dicc_offset 28

extern free
extern malloc
extern is_constant
extern is_true
extern is_false
extern obdd_node_print
extern dictionary_add_entry
extern obdd_mgr_get_next_node_ID


section .data
global obdd_mgr_mk_node
global obdd_node_destroy
global obdd_create
global obdd_destroy
global obdd_node_apply
global is_tautology
global is_sat
global str_len
global str_copy
global str_cmp

section .text

obdd_mgr_mk_node:
;pusha
push rdi
push rsi
push rdx
push rcx
push r12
push r13
push r15
push r15
mov rdi, obdd_node_size
call malloc

;pop rcx
;pop rdx
pop rsi
pop rdi NO PUEDO HACER ESTO, LIFO!!!
ARREGLARLO!!!
;popa
mov r8, rax;En r8 tengo el puntero a memoria

mov r9, rdi
;mov r10, rsi
mov rdi, [r9+mgr_vars_dicc_offset]
call dictionary_add_entry; acá hago new_node->var_id = var_ID
mov r10d, eax; En r10 tengo el dicc entry
mov rdi, r9; restauro rdi
call obdd_mgr_get_next_node_ID
mov r11d, eax; Me estoy quedando sin registros, si sigo así voy a tener que mandar cosas a pila

pop rcx;Me los traigo ahora por que antes tenía calls que me los podían modificar
pop rdx;y tampoco era necesario traelos antes por que no los usaba ninguna de las funciones que llamé

mov [r8+obdd_node_var_ID_offset], r10d
mov [r8+obdd_node_node_ID_offset], r11d
mov [r8+obdd_node_ref_count_offset], 0
mov [r8+obdd_node_high_offset], rdx
mov [r8+obdd_node_low_offset], rcx

cmp rdx, NULL; comparo el High de entrada con NULL
je .sig_comparacion
add dword [r8+obdd_node_ref_count_ofset], 1
mov [r8+obdd_node_low_offset], rcx;EN RCX ESTÁ LOW
;high -> ref_count++
;new_node -> low_obdd = low

.sig_comparacion:
cmp rcx, NULL; comparo el Low de entrada con NULL
je .fin
add dword [rcx+obdd_node_ref_count], 1;EN RCX ESTA LOW. MODIFICARLO CUANDO ARREGLE LA PILA
mov dword [r8+obdd_node_ref_count_offset], 0


.fin:
mov rax, r8; Pongo en el resultado la dirección de r8 que me paso malloc, y donde fui completando
;todos los campos del nuevo nodo.
y todos los pops

ret

obdd_node_destroy:
ret

obdd_create:
push rbp
mov rbp, rsp;Me armo la pila por el malloc
mov r8, rdi; Acá tengo los parametros que paso
;mov r9, rsi;
mov rdi, obdd_size;
call malloc;En rax tengo un puntero a un lugar de
;memoria de tamaño obdd_size
mov [rax+obdd_manager_size], r8
mov [rax+obdd_root_size], rsi; No se debería haber modificado rsi, así que lo uso
pop rbp
;NECESITO ARMAR LA PILA ACA?
ret

obdd_destroy:
;NECESITO ARMAR LA PILA ACA? YO CREO QUE NO
cmp qword [rdi+obdd_root_size], NULL
je .ManagerDelete
mov r8, rdi
mov rdi, [rdi+obdd_root_size]
call obdd_node_destroy
mov rdi, r8;Restauro rdi, por que despues de ciclar lo necesito
mov qword [rdi+obdd_root_size], NULL
.ManagerDelete:
mov qword [rdi+obdd_root_size], NULL
call free;Libero la memoria dinamica que estaba usando ahí
ret

obdd_node_apply:
ret

is_tautology:
;La implementacion en C es igual a la de is_sat, así que acá también
mov r8, rdi
mov r9, rsi
call is_constant
cmp rax, 0
jnz .constant
mov rdi, r8
mov rsi, [r9+obdd_node_high_offset]
call is_tautology
mov rdi, r8
mov rsi, [r9+obdd_node_low_offset]
call is_tautology
ret

.constant:
mov r8, rdi
mov r9, rsi
call is_true
ret

is_sat:
mov r8, rdi
mov r9, rsi; Me guardo rdi y rsi
call is_constant
cmp rax, 0; es constante? Iguales=Constante, Distintos=No es constante
jnz .not_constant; Si 
mov rdi, r8
mov rsi, [r9+obdd_node_high_offset]; En rsi la rama alta del nodp
call is_sat
mov r10, rax;Guardo el resultado en r10
mov rdi, r8; Restauro rdi
mov rsi, [r9+obdd_node_low_offset];Pongo en rsi la rama baja del noro
call is_sat
mov r11, rax; Ahora tengo en r10 y r11 los resultados
ret
;jmp .terminar

.not_constant:
mov rdi, r8
mov rsi, r9
call is_true
;.terminar:
ret

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

