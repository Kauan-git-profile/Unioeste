; Esse código identifica dois floats entrados pelo user
; nasm -f elf64 [LM_pratica_02]KauanCampos_MatheusLopes.asm && gcc -m64 -no-pie [LM_pratica_02]KauanCampos_MatheusLopes.o -o exercicio2

extern printf
extern scanf
extern fprintf
extern fopen
extern fclose
extern atof

section .data
    
    input : db "%f %c %f", 0
    file  : db "Resultados.txt", 0 ; nome do arquivo que conterá as respostas
    modo  : db "a", 0 ; modo de inserção ao fim do arquivo

    answer      : db "%.2lf %c %.2lf = %.2lf", 10, 0
    errorAnswer : db "%.2lf %c %.2lf = funcionalidade não disponível", 10, 0

    strError: db "Erro ao abrir o arquivo!!!", 10, 0

section .bss
    float1 : resd 1 ;Precisão simples
    float2 : resd 1
    float3 : resd 1
    oper   : resb 1 

    arquivo : resq 1

section .text 
    global main

 adicao:
    push rbp
    mov rbp, rsp ;StackFrame 
    ADDSS xmm0, xmm1
    movss [float3], xmm0
    mov rsp, rbp
    pop rbp ;DestackFrame
    ret
    
subtracao:
    push rbp
    mov rbp, rsp ;StackFrame 
    SUBSS xmm0, xmm1
    movss [float3], xmm0
    mov rsp, rbp
    pop rbp ;DestackFrame
    ret

multiplicacao:
    push rbp
    mov rbp, rsp ;StackFrame 
    MULSS xmm0, xmm1
    movss [float3], xmm0
    mov rsp, rbp
    pop rbp ;DestackFrame
    ret

divisao:
    push rbp
    mov rbp, rsp ;StackFrame 
    DIVSS xmm0, xmm1
    movss [float3], xmm0
    mov rsp, rbp
    pop rbp ;DestackFrame
    ret


escrevesolucaoOK:
    push rbp
	mov rbp, rsp

    mov rdi, [arquivo]
    mov rsi, answer
    cvtss2sd xmm0, [float1]
    cvtss2sd xmm1, [float2]
    cvtss2sd xmm2, [float3]
    movzx rdx, byte [oper]
    mov rax, 3
    
    call fprintf

    mov rdi, [arquivo]
    call fclose
    
    mov rsp, rbp
    pop rbp
    ret

escrevesolucaoNOTOK:
    push rbp
    mov rbp, rsp

    mov rdi, [arquivo]
    mov rsi, errorAnswer
    cvtss2sd xmm0, [float1]
    cvtss2sd xmm1, [float2]
    movzx rdx, byte [oper]
    mov rax, 2
    
    call fprintf

    mov rdi, [arquivo]
    call fclose

    mov rsp, rbp
    pop rbp
    ret

main:
    
    push rbp
    mov rbp, rsp ;Stack frame

    mov rdi, [rsi + 8]
    mov rbx, rsi
    xor esi, esi
    call atof
    mov rax, [rbx + 16]
    mov rdi, [rbx + 24]
    xor esi, esi
    cvtsd2ss xmm0, xmm0
    movss [float1], xmm0  
	movzx eax, byte [rax] 
	mov [oper], al
	call atof             
	cvtsd2ss xmm0, xmm0    
	movss [float2], xmm0 

reg:
    Fopen:
    mov rdi, file
    mov rsi, modo
    call fopen
    mov [arquivo], rax

    test rax, rax   ; Verifica se fopen retornou NULL
    jz erro1   ; Se fopen falhar, pula para erro

    movss xmm0, [float1]
    movss xmm1, [float2]

    ;escolha da operação baseada na entrada do usuário
    compar:
    cmp dword [float2], 0
    je erro2
    cmp byte [oper], 'a'
    je sum
    cmp byte [oper], 's'
    je sub
    cmp byte [oper], 'm'
    je mult
    cmp byte [oper], 'd'
    je div
    jmp erro2

    sum:
        call adicao
        mov byte [oper], '+'
        call escrevesolucaoOK
        jmp fim
        
    sub:
        call subtracao
        mov byte [oper], '-'
        call escrevesolucaoOK
        jmp fim

    mult:
        call multiplicacao
        mov byte [oper], '*'
        call escrevesolucaoOK
        jmp fim

    div:
        call divisao
        mov byte [oper], '/'
        call escrevesolucaoOK
        jmp fim

    erro2:
        call escrevesolucaoNOTOK
        jmp fim

    erro1:
        mov rdi, strError
        call printf
        jmp fim

fim:
    mov rsp, rbp
    pop rbp ;destack frame

    mov rax, 60
    mov rdi, 0
    syscall