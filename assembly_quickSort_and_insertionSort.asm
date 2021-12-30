.data
message1: 	.asciiz "Vetor lido no arquivo: "
message2: 	.asciiz "Quantidade de números:  "
message3: 	.asciiz "Vetor de inteiros: "
message4: 	.asciiz "Por favor, insira o nome do arquivo: " 
message5:       .asciiz "Qual algoritmo de ordenação? 1 - InsertionSort | 2 - QuickSort: "
message6:       .asciiz "Resultado escrito no arquivo."
message7:       .asciiz "QuickSort escolhido."
message8:       .asciiz "InsertionSort escolhido."
message9:       .asciiz "Valor inválido. Por favor insira um valor válido [1 - InsertionSort | 2 - QuickSort]"
messageFile:    .asciiz "Vetor ordenado: "
space:    	.asciiz " "          
enter: 		.asciiz "\n "

tamOutput:      .align 3
		.space 1024

array: 
		.align 2
		.space 1024            		#Array para até 256 inteiros

diretorio:   	.space 1024
bufferLeitura:  .space 1024
str:		.space 1024
str2:		.space 1024

.text
.globl main

main:
	jal solicitaEntrada
	jal leEntradaUsuario
	jal trataEntrada  			# Remove alguns valores hexadecimais no nome do arquivo
	jal leArquivo
	jal imprimeSaidaPadrao
	jal contaNumeros
	jal imprimeQuantidade
	jal separaNumeros
	jal imprimeArrayInteiros
	jal solicitaAlgoritmo
	
	move $a0, $s7   			# $a0 <-- Tamanho do vetor
	move $a1, $s5				# $a1 <-- Escolha do algoritmo
	la $a2, array				# $a2 <-- Base do array
	
	jal ordena
	jal imprimeArrayInteiros
	jal converteIntParaString
	jal escreveResultado
	jal terminaPrograma

ImprimeMensagem:      #imprimeMensagem (char[] a, bool InteiroOuString)
	beqz $a1, ImprimeInteiro
	li $v0, 4
	syscall
	j NovaLinha
ImprimeInteiro:
	li $v0, 1
	syscall
NovaLinha:
	#imprime nova linha já com carriage return
	li $v0, 0xB
	li $a0, 0xA
	syscall
	jr $ra	

converteIntParaString:
	addi $sp, $sp, -4			# Aloca espaço na pilha
	sw $ra, 0($sp)      			# Guarda o $ra
	la $t3, array
	li $t9, 0       			# Início do contador
	la $t4, space    			# $t4 tem o endereço para o espaço em ASCII
	lb $t5, 0($t4)   			# $t5 tem o byte do spaço
	la $t6, str2				# $t6 é a base do vetor em ASCII
ConverteIntParaStringLoop:
	slt $t1, $t9, $s7
	beqz $t1, FimConverte
	mul $t2, $t9, 4 			# Indicador do índice array[i]
	add $t2, $t3, $t2			# Acessa array[i]
	lw $a0, 0($t2)
	la $a1, str
	jal itoa
	la $a0, str

whileDeposito:
	lb $t8, 0($a0)		     		#Carrega um byte de $a0
	beqz $t8, fimWhileDeposito   		#Verifica se chegou no último byte de $a0
	sb $t8, 0($t6)    			# Armazena o byte de $a0
	add $t6, $t6, 1   			# Avança no array final
	add $a0, $a0, 1   			# Avança um byte em $a0
	j whileDeposito

fimWhileDeposito:
	sb $t5, 0($t6)   			# Armazena o byte de espaço
	add $t6, $t6, 1   			# Avança no arrau final
	add $t9, $t9, 1 			# i++
	j ConverteIntParaStringLoop
	
FimConverte:

	lw $ra, 0($sp)
	addi $sp, $sp, 4    			# Restaura a pilha
	jr $ra

itoa:
	addi $sp, $sp, -4         		# Aloca um espaço na pilha
	sw   $t0, ($sp)            
	bltz $a0, neg_num         		# num < 0 ?
	j    next0                		# se num > 0, acessa 'next0'
neg_num:                  			# Se num < 0
	li   $t0, '-'
	sb   $t0, ($a1)           		# Código ASCII do '-' 
	addi $a1, $a1, 1          		# str++
	li   $t0, -1
	mul  $a0, $a0, $t0        		# num *= -1
next0:
	li   $t0, -1
	addi $sp, $sp, -4         		# Aloca espaço na pilha
	sw   $t0, ($sp)           		# Salva -1 (marcador do fim da pilha)
push_digitos:
	blez $a0, next1           		# num < 0? Se sim, fim do loop
	li   $t0, 10              
	div  $a0, $t0             		# num / 10. LO = Quociente, HI = Resto
	mfhi $t0                  		# $t0 = num % 10
	mflo $a0                  		# num = num / 10  
	addi $sp, $sp, -4         		# Aloca espaço na pilha
	sw   $t0, ($sp)           		# Armazena num % 10 calculado 
	j    push_digitos         		# Loop
next1:
	lw   $t0, ($sp)           		# $t0 = "dígito retirado da pilha"
	addi $sp, $sp, 4          		# Restaura a pilha
	bltz $t0, neg_digit      		# Se dígito <= 0, acessa neg_digit
	j    pop_digitos          		# Caso contrário, acessa pop_digitos
neg_digit:
	li   $t0, '0'
	sb   $t0, ($a1)           		# *str = ASCII de '0'
	addi $a1, $a1, 1          		# str++
	j    next2                
pop_digitos:
	bltz $t0, next2           		# Se o dígito <= 0 fim do loop
	addi $t0, $t0, '0'        		# $t0 = Código ASCII do dígito
	sb   $t0, ($a1)           		# *str = Código ASCII do dígito
	addi $a1, $a1, 1          		# str++
	lw   $t0, ($sp)           		# Retira o dígito da pilha 
	addi $sp, $sp, 4          		# Restaura a pilha
	j    pop_digitos          
next2:
	sb  $zero, ($a1)          		# *str = 0 | Marcador do fim da String
	lw   $t0, ($sp)           		# Restaura o $t0 
	addi $sp, $sp, 4          		# Restaura a pilha
	jr  $ra                   
				
solicitaEntrada:
	add $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, message4 
	li $a1, 1				# Argumento para impressão de String
	jal ImprimeMensagem			# Chama função ImprimeMensagem
	lw $ra, 0($sp)				# Restaura $ra	   
	addi $sp, $sp, 4			# Restaura a pilha
	jr $ra
	
leEntradaUsuario:
	li $v0, 8
	la $a0, diretorio
	li $a1, 1024
	syscall	
	jr $ra

trataEntrada:
    	li $t0, 0       			# Contador do loop
    	li $t1, 100     			# Flag do loop
RemoveHex:
    	beq $t0, $t1, fimTrataNome
    	lb $t3, diretorio($t0)
    	bne $t3, 0x0a, Add
    	sb $zero, diretorio($t0)    		# Remove 0x0a da string do nome
Add:
    	addi $t0, $t0, 1
    	j RemoveHex
fimTrataNome:
    	jr $ra

leArquivo:
	#abertura do arquivo
	li $v0, 13                               #Chamada para abertura do arquivo
	la $a0, diretorio
	li $a1, 0			 	 #Código para leitura de arquivo (0)
	syscall
	move $s0, $v0
	#leitura do arquivo
	li $v0, 14
	move $a0, $s0
	la $a1, bufferLeitura
	la $a2, 1024
	syscall
	#fecha arquivo
	li $v0, 16
	move $a0, $s0
	syscall
	jr $ra
	
imprimeSaidaPadrao:
	add $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, message1
	li $a1, 1				# Argumento para impressão de String
	jal ImprimeMensagem
	la $a0, bufferLeitura
	jal ImprimeMensagem
	lw $ra, 0($sp)				# Restaura $ra	   
	addi $sp, $sp, 4			# Restaura a pilha

contaNumeros:
	li $s7, 1 				 # Índice contador de números iniciado em 1
	la $t0, bufferLeitura			 # Carrega em $t0 o conteúdo lido para contagem de números
LoopContaNumeros:
	li $t2, 32				 # Carrega 32 para identificar o espaço
	add $s3, $s3, 1
	lb $t1, 0($t0)		 		 # Carrega em $t1 o primeiro byte do array
	beqz $t1, FimContaNumeros 		 # Se chegar ao final do arquivo (byte 0) então termina o loop
	beq $t1, $t2, IncrementaNumero		 # Se encontrar um espaço (32 dec em ASCII), incrementa o contador de números
	add $t0, $t0, 1				 # Se encontrar outro número, avança o array
	j LoopContaNumeros			 # Retorna ao laço              				 
IncrementaNumero:
	add $s7, $s7, 1				 # Incrementa 1 unidade a contagem de números em $s7
	add $t0, $t0, 1 			 # Avança o array	
	j LoopContaNumeros			 # Retorna ao laço ContaNumeros
FimContaNumeros:
	jr $ra 
	
imprimeQuantidade:
	add $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, message2
	li $a1, 1
	jal ImprimeMensagem
	move $a0, $s7
	li $a1, 0				# Argumento para impressão de inteiro
	jal ImprimeMensagem
	lw $ra, 0($sp)				# Restaura $ra	   
	addi $sp, $sp, 4			# Restaura a pilha
	jr $ra
	
separaNumeros:
	la $t0, bufferLeitura
	li $t4, 0				 # Carrega em $t4 o valor 0 para converter os números contíguos no conteúdo
	la $s1, array   			 # Carrega em $t5 o array para armazenar os números lidos
LoopSeparaNumeros:
	li $t2, 32				 # Carrega 32 para identificar o espaço
	lb $t1, 0($t0)		 		 # Carrega em $t1 o primeiro byte do array
	beqz $t1, FimSeparaNumeros 		 # Se chegar ao final do arquivo (byte 0) então termina o loop
	beq $t1, $t2, AvancaVetor		 # Se encontrar um espaço (32 dec em ASCII), acessa AvancaVetor e guarda o valor no array
	add $t3, $t1, -48			 # Converte o valor em ASCII para decimal 
	mul $t4, $t4, 10			 # Multiplica o último valor por 10, pois há incremento de uma unidade de significância
	add $t4, $t4, $t3			 # Soma o valor armazenado com o último valor contíguo lido
	add $t0, $t0, 1				 # Avança uma posição do vetor de leitura
	j LoopSeparaNumeros			 # Retorna ao laço
AvancaVetor:
	sw $t4, 0($s1)				 # Armazena o valor na posição de memória
	add $s1, $s1, 4				 # Avança uma posição do vetor de armazenamento. Avança uma palavra
	add $t0, $t0, 1				 # Avança uma posição do vetor de leitura. Avança um byte
	li $t4, 0				 # Reset no acumulador para conversão decimal de números contíguos
	j LoopSeparaNumeros			 # Salta para o rótulo SeparaNumeros	 
FimSeparaNumeros:
	sw $t4, 0($s1)				 # Armazena o valor na posição de memória
	jr $ra

imprimeArrayInteiros:
	add $sp, $sp, -4
	sw $ra, 0($sp)
	la $s1, array
	li $t0, 0
	la $a0, message3
	li $a1, 1
	jal ImprimeMensagem
	
ImprimeArrayInteirosLoop:
	beq $t0, $s7, FimImprimeArrayInteiros
	lw $a0, 0($s1)
	li $v0, 1
	syscall
	la $a0, space
	li $v0, 4
	syscall
	add $s1, $s1, 4
	add $t0, $t0, 1
	j ImprimeArrayInteirosLoop	
FimImprimeArrayInteiros:
	li $v0, 0xB
	li $a0, 0xA
	syscall
	lw $ra, 0($sp)				# Restaura $ra	   
	addi $sp, $sp, 4			# Restaura a pilha
	jr $ra
	
solicitaAlgoritmo:
	add $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, message5
	li $a1, 1
	jal ImprimeMensagem
LeEscolhaAlgoritmo:
	li $t0, 0				# Garante que $t0 seja 0
	li $v0, 5				# Lê a escolha do algoritmo (1 - InsertionSort | 2 - QuickSort)
	syscall
	seq $t0, $v0, 1				# Indica se $v0 é igual a 1
	move $t2, $t0
	seq $t0, $v0, 2				# Indica se $v0 é igual a 2
	move $t3, $t0
	add $t0, $t2, $t3
	beqz $t0, AlgoritmoInvalido	
	move $s5, $v0
	lw $ra, 0($sp)				# Restaura $ra	   
	addi $sp, $sp, 4			# Restaura a pilha
	jr $ra		
AlgoritmoInvalido:
	la $a0, message9
	jal ImprimeMensagem
	j LeEscolhaAlgoritmo	
	
ordena:
	addi $sp, $sp, -16
	sw $a0, 0($sp)      			 # 0($sp) recebe o tamanho do array
	sw $a1, 4($sp)      			 # 4($sp) recebe a escolha do algoritmo
	sw $a2, 8($sp)      			 # 8($sp) recebe o vetor
	sw $ra, 12($sp)     			 # 12($sp)recebe $ra	
	beq $a1, 1, InsertionSortAlg 
	beq $a1, 2, QuickSortAlg
	j FimOrdena	
InsertionSortAlg:
	la $a0, message8
	li $a1, 1
	jal ImprimeMensagem
        jal InsertionSort
        j FimOrdena 
QuickSortAlg:
	la $a0, message7
	li $a1, 1
	jal ImprimeMensagem
	jal QuickSortMain
FimOrdena:
	lw $a0, 0($sp)          		 # Restaura $a0
	lw $a1, 4($sp)          		 # Restaura $a1
	lw $a2, 8($sp)          		 # Restaura $a2
	lw $ra, 12($sp)         		 # Restaura $ra
	addi $sp, $sp, 16       		 # Restaura a pilha
	jr $ra              			 # Retorna ao invocador	
	
escreveResultado:
	add $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, message6
	jal ImprimeMensagem
	#abertura do arquivo
	li $v0, 13                               #Chamada para abertura do arquivo
	la $a0, diretorio
	li $a1, 9			 	 #Código para escrita anexada ao conteúdo existente
	syscall
	move $s0, $v0
	#escrever no final do arquivo
	li $v0, 15
	move $a0, $s0
	la $a1, enter
	li $a2, 1
	syscall
	li $v0, 15
	move $a0, $s0
	la $a1, messageFile
	li $a2, 17
	syscall
	li $v0, 15
	move $a0, $s0
	la $a1, str2				# O vetor ordenado é escrito no final do arquivo
	li $a2, 1024
	syscall
	#fechar arquivo
	li $v0, 16
	move $a0, $s0
	syscall
	lw $ra, 0($sp)				# Restaura $ra	   
	addi $sp, $sp, 4			# Restaura a pilha
	jr $ra

InsertionSort:
	li $t3, 0				 # $t3 <- aux
	li $t0, 1				 # $t0 <- K
	move $t1, $s7
Loop1:
	la $t4, array				 # $t4 <- base array
	slt $t5, $t0, $t1			 # $t0 < $t1?
	beqz $t5, fim				 # Pula para fim do loop se percorrer todo o array ($t0 = $t1)
	mul $t2, $t0, 4				 # Determina a posição do vetor de inteiros
	add $t4, $t4, $t2			 # Indica o índice K do array
	lw $t3, 0($t4)				 # Armazena em $t3 a posição K do array --- aux = array[k]
	add $t6, $t0, -1			 # $t6 <-- k - 1 (J)
	j Loop2
Loop2:
	slti $t7, $t6, 0			 # $t6 (J) < 0
	li $t5, 1
	beq $t7, $t5, Loop1Cont 		 # Se $t6 < 0, então pula para a continuação do loop1
	mul $t8, $t6, 4         		 # $t8 carrega o indicador do índice J
	la $t4, array
	add $t4, $t4, $t8			 # Acessa o índice J do array
	lw $t7, 0($t4)				 # $t7 <-- array[J]
	li $t8, 0
	slt $t8, $t3, $t7			 # $t3 < $t7? <--> aux < array[J]?
	beqz $t8, Loop1Cont 			 # Sai do loop2 se $t3 > $t7 <--> aux > array[J]
	add $t8, $t6, 1 			 # $t8 <-- J + 1
	mul $t9, $t8, 4				 # $t9 <-- indicador do índice J+1
	la $t4, array
	add $t4, $t4, $t9			 # Acessa o índice J+1 do array
	sw $t7, ($t4)				 # Array[J + 1] = Array[J]
	add $t6, $t6, -1			 # J--
	j Loop2
Loop1Cont:
	add $t6, $t6, 1				 # $t6 armazena J+1
	mul $t4, $t6, 4				 # $t4 armazena o indicador do índice J+1 do array
	la $t7, array				 # Carrega em $t7 o array
	add $t7, $t7, $t4			 # Acessa a posicão J+1 do array
	sw $t3, 0($t7)				 # Array[J + 1] <-- aux
	add $t0, $t0, 1				 # K++
	j Loop1
fim:
	move $v0, $s7				 # Tamanho do vetor resultante (idem ao tamanho do vetor original)
	jr $ra

QuickSortMain:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $s6, $s7, -1
	
			
	la $t0, array 
	addi $a0, $t0, 0 
	addi $a1, $zero, 0 			 # Define argumento 1 como 0 (LOW)
	add $a2, $zero, $s6      		 # Define argumento 2 como tamanho do array - 1 a ser ordenado
	jal quicksort 				 # Chama quickSort
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4

particao:
	addi $sp, $sp, -16  			 # Aloca 4 espaços na pilha 
	sw $a0, 0($sp)      			 # 0($sp) recebe a base do endereço do array
	sw $a1, 4($sp)      			 # 4($sp) recebe LOW
	sw $a2, 8($sp)      			 # 8($sp) recebe HIGH
	sw $ra, 12($sp)     			 # 12($sp)recebe $ra
	move $s1, $a1	    			 # s1 <- LOW
	move $s2, $a2	    			 # s2 <- HIGH
	mul $t1, $s1, 4				 # Determina indicador de índice para arr[low]
	add $t1, $a0, $t1			 # Acessa a posição arr[low]
	lw $t2, 0($t1)  			 # $t2 <--- Pivot | array[LOW]  
	move $t8, $a1   			 # $t8 <--- LOW  | $t8 = LEFT          
	move $t9, $a2   			 # $t9 <--- HIGH | $t9 = RIGHT
while1:
	slt $t7, $t8, $t9   			 # $t8 < $t9?
	beqz $t7, fimWhile1			 # Se $t8 > $t9, então se encerra o laço principal
while2: 
	mul $t6, $t8, 4	    			 # Determina índice para a posição arr[LEFT]
	add $t6, $a0, $t6   			 # Acessa arr[LEFT]
	lw $t5, 0($t6)      			 # $t5 <--- arr[LEFT]
	sle $t7, $t5, $t2   			 # $t5 <= $t2? | arr[LEFT] <= pivot?
	beqz $t7, while3			 # Se arr[LEFT] > pivot, então se encerra o laço while2
	sle $t7, $t8, $s2   			 # $t8 <= $s2?  | LEFT <= HIGH?
	beqz $t7, while3			 # Se LEFT > HIGH, então se encerra o laço while2
	add $t8, $t8, 1        			 # LEFT++
	j while2				 # Loop 
while3:
	mul $t6, $t9, 4     			 # Determina índice para a posição arr[RIGHT]
	add $t6, $a0, $t6   			 # Acessa arr[RIGHT]
	lw $t5, 0($t6)      			 # $t5 <--- arr[RIGHT]
	slt $t7, $t2, $t5   			 # pivot < arr[RIGHT]?
	beqz $t7, if				 # Se pivot > arr[RIGHT], então se encerra o while3
	slti $t7, $t9, 0    			 # $t9 < 0? | RIGHT < 0?
	bnez $t7, if        			 # Se $t9 < 0, então se encerra o while
	addi $t9, $t9, -1   			 # RIGHT--
	j while3				 # Loop
if: 
	slt $t7, $t8, $t9   			 # LEFT < RIGHT?
	beqz $t7, while1    			 # Se LEFT > RIGHT, então volta ao while1
	mul $t6, $t8, 4     			 # $t6 recebe o indicador de índice array[LEFT]
        add $t6, $a0, $t6   			 # Acessa arr[LEFT] 
        lw $t5, 0($t6)	    			 # $t5 <-- arr[LEFT]  | $t5 = AUX 
	mul $t7, $t9, 4     			 # $t7 recebe o indicador de índice array[RIGHT]
	add $t7, $a0, $t7   			 # Acessa arr[RIGHT] 
	lw $t4, 0($t7)      			 # $t4 <-- arr[RIGHT] 
	sw $t4, 0($t6)      			 # arr[LEFT] = arr[RIGHT]
	sw $t5, 0($t7)      			 # arr[RIGHT] = aux
	j while1
fimWhile1:
	mul $t1, $s1, 4     			 # Determina indicador de índice arr[low]
	add $t1, $a0, $t1   			 # Acessa a posição arr[low] 
	mul $t3, $t9, 4     			 # Determina indicador de índice arr[rig]
	add $t3, $a0, $t3   			 # Acessa a posição arr[rig] 
	lw $t5, 0($t3)	    			 # $t5 <-- arr[rig] 	
	sw $t5, 0($t1)	    			 # arr[low] = arr[rig]
	sw $t2, 0($t3)      			 # arr[rig] = pivot
	move $v0, $t9       			 # Returna RIGHT (Pivô)
	lw $ra, 12($sp)     			 # Carrega $ra para retornar ao invocador
	addi $sp, $sp, 16   			 # Restaura a pilha
        jr $ra              			 # Salta ao invocador
quicksort:              
	addi $sp, $sp, -16      		 # Aloca 4 espaços na pilha 
	sw $a0, 0($sp)          		 # 0($sp) recebe a base do endereço do array
	sw $a1, 4($sp)          		 # 4($sp) recebe LOW
	sw $a2, 8($sp)          		 # 8($sp) recebe HIGH
	sw $ra, 12($sp)         		 # 12($sp)recebe $ra
	move $t0, $a2           		 # $t0 <-- HIGH
	slt $t1, $a1, $t0       		 # LOW < HIGH?
	beq $t1, $zero, fimIf           	 # Se LOW >= HIGH, acessa fimIf
	jal particao           			 # Invoca particao 
	move $s0, $v0           		 # $s0 <-- $v0 | O valor do pivô é atribuído a $s0
	lw $a1, 4($sp)          		 # Carrega no argumento $a1 o valor de LOW
	addi $a2, $s0, -1       		 # Carrega no argumento $a2 'pi - 1', isto é, o vizinho esquerdo do pivô
	jal quicksort           		 # Chamada recursiva a quickSort da partição esquerda
	addi $a1, $s0, 1        		 # Carrega no argumento $a1 o valor 'pi + 1', isto é, o vizinho direito do pivô
	lw $a2, 8($sp)          		 # Carrega no argumento $a2 o valor de HIGH
	jal quicksort           		 # Chamada recursiva a quickSort da partição direita
fimIf:
	lw $a0, 0($sp)          		 # Restaura $a0
	lw $a1, 4($sp)          		 # Restaura $a1
	lw $a2, 8($sp)          		 # Restaura $a2
	lw $ra, 12($sp)         		 # Restaura $ra
	addi $sp, $sp, 16       		 # Restaura a pilha
	move $v0, $s7				 # Tamanho do vetor resultante (idem ao tamanho do vetor de origem)
	jr $ra              			 # Retorna ao invocador

terminaPrograma:
	li $v0, 10
	syscall
	


