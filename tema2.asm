;Anca Millio, 325 CA

extern puts
extern printf
extern strlen

%define BAD_ARG_EXIT_CODE -1

section .data
filename: db "./input0.dat", 0
inputlen: dd 2263

fmtstr:            db "Key: %d",0xa, 0
usage:             db "Usage: %s <task-no> (task-no can be 1,2,3,4,5,6)", 10, 0
error_no_file:     db "Error: No input file %s", 10, 0
error_cannot_read: db "Error: Cannot read input file %s", 10, 0

section .text
global main

xor_strings:
	; TODO TASK 1
       push ebp
       mov ebp, esp
       mov eax, [ebp + 8] ; text               ;preiau argumentele
       mov ebx, [ebp + 12] ; cheie
       dec ecx
do_xor: 
       mov byte dl, [eax + ecx]                ;citesc cate un otet din fiecare(text si cheie) 
       mov byte dh, [ebx + ecx]
       xor dl, dh                              ;fac xor, apoi pun rezultatul inapoi in sir
       mov byte [eax + ecx], dl
       dec ecx
       cmp ecx, -1                             ;verific daca am ajuns la finalul sirului
       jg do_xor
       leave
	ret

rolling_xor:
	; TODO TASK 2
       push ebp
       mov ebp, esp
       mov eax, [ebp + 8]                      ;preiau sirul criptat
       
       mov ecx, 0
       mov byte dl, [eax + ecx]
continue:
       inc ecx
       mov byte bl, [eax + ecx]
       cmp bl, 0x00                            
       je done
       xor bl, dl                              ;fac xor intre doi octeti consecutivi
       mov byte dl, [eax + ecx]                ;inainte de a pune rezultatul in sir, iau vechea valoare din
                                               ;octetul respectiv pentru a o folosi la urmatorul xor
       mov byte [eax + ecx], bl                ;rezultatul il pun inapoi in sir
       jmp continue
done:       
       leave
	ret

xor_hex_strings:
	; TODO TASK 3
       push ebp
       mov ebp, esp
       mov eax, [ebp + 8] ; text
       
       mov ecx, 0
       xor edx, edx
       mov edx, -1;
read_string:
       mov bh, 0
       mov bl, 0
       mov byte bl, [eax + ecx]                  ;citesc cate doi octeti consecutivi(pentru un numar in hexa imi trebuie doua caractere)
       mov byte bh, [eax + ecx + 1]
       cmp bl, 0x00                              ;daca am parcurs tot sirul, trec la parcurgerea cheii in acelasi mod
       je key 
       inc ecx
       inc edx     
       cmp bl, 'a'                               ;verific daca caracterul curent este cifra sau litera
       jl string_get_number_bl
       sub bl, 'W'                               ;daca este litera, obtin intregul necesar facand diferenta cu W
bh_to_number:
       cmp bh, 0x00                              ;daca am ajuns la finalul sirului pe poztia lui bh, trebuie sa pun totusi
                                                 ;in sirul rezultat, valoarea calculata in bl(octetul anterior)
       je string_put_bl
       inc ecx
       cmp bh, 'a'                               ;fac transformarea lui bh in intreg asemenea lui bl
       jl string_get_number_bh
       sub bh, 'W'
string_get_hex:
       ;add ecx, 2
       xor eax, eax                              ;avem cele doua valori intregi din care constituim numarul in hexa
       mov al, bl                                ;prima valoare se inmulteste cu 16, apoi se adauga a doua valoare
       mov bl, 16
       mul bl
       add al, bh
       mov bl, al
       xor eax, eax
       mov eax, [ebp + 8]
       mov byte [eax + edx], bl                  ;punem numarul hexa rezultat in sirul(text criptat) primit ca argument
                                                 ;deoarece din doi octeti se obtine in final unul singur, este sigur 
                                                 ;faptul ca nu voi suprascrie octeti pe care inca nu i-am prelucrat
       xor ebx, ebx
       jmp read_string
string_get_number_bh:                                   ;il transform pe bh in intreg ca la eticheta "get_number"
       sub bh, '0'
       jmp string_get_hex       
string_get_number_bl:                                      ;daca este cifra, il scad pe zero pentru a obtine din carater, un intreg
       sub bl, '0'
       jmp bh_to_number
string_put_bl:                                          ;intregul din bl va fi pus in sirul criptat(text) dupa cum am explicat mai sus
       mov byte [eax + edx], bl   
       xor eax, eax    
key:                                             ;se parcurg si transforma in intregi octetii cheii, la fel ca sirul criptat
       mov eax, [ebp + 12] ;cheie
       mov ecx, 0
       xor edx, edx
       mov edx, -1
key_read:
       mov bh, 0
       mov bl, 0
       mov byte bl, [eax + ecx]
       mov byte bh, [eax + ecx + 1]
       cmp bl, 0x00
       je  stop
       inc ecx
       inc edx     
       cmp bl, 'a'
       jl key_get_number_bl
       sub bl, 'W'
key_bh_to_number:
       cmp bh, 0x00
       je key_put_bl
       inc ecx
       cmp bh, 'a'
       jl key_get_number_bh
       sub bh, 'W'
key_get_hex:
       ;add ecx, 2
       xor eax, eax
       mov al, bl
       mov bl, 16
       mul bl
       add al, bh
       mov bl, al
       xor eax, eax
       mov eax, [ebp + 12]
       mov byte [eax + edx], bl
       xor ebx, ebx
       jmp key_read
key_get_number_bh:
       sub bh, '0'
       jmp key_get_hex    
key_get_number_bl:
       sub bl, '0'
       jmp key_bh_to_number
key_put_bl:
       mov byte [eax + edx], bl  
stop:                                                ;atat sirul criptat(text), cat si cheia au fost transformate in numere hexa
       mov eax, [ebp + 8] ; text
       mov ebx, [ebp + 12] ; cheie
       xor ecx, ecx                                  
       mov ecx, edx
       mov byte [eax + ecx + 1], 0x00                ;punem terminatorul de sipentru a nu citi apoi mai mult decat trebuie
do_hex_xor: 
       xor edx, edx
       mov byte dl, [eax + ecx]      
       mov byte dh, [ebx + ecx]
       xor dl, dh                                    ;se face xor pe cate doi octeti din cele doua siruri
       mov byte [eax + ecx], dl                      ;rezultatul se pune tot in sirul care a fost decriptat
       dec ecx
       cmp ecx, -1
       jg do_hex_xor
                
       leave
	ret

base32decode:
	; TODO TASK 4
       push ebp
       mov ebp, esp
       mov eax, [ebp + 8]   ;text
       mov ecx, 0
       mov ebx, -1
       push ebx ;indexul pt sirul format
       xor ebx, ebx
convert_5_bytes:
       mov byte bl, [eax + ecx]
       cmp bl, 0x00
       je get_chars
       shr bl, 3
       pop eax
       inc eax
       mov byte [edx + eax], bl   ;val 1
       push eax
       mov eax, [ebp + 8]   ;text
       xor ebx, ebx
       mov word bx, [eax + ecx]
       shl bx, 5
       shr bx, 11
       pop eax
       inc eax
       mov byte [edx + ecx + 1], bl   ;val 2
       push eax
       mov eax, [ebp + 8]   ;text
       xor ebx, ebx
       mov byte bl, [eax + ecx + 1]
       shl bl, 2
       shr bl, 3
       pop eax
       inc eax
       mov byte [edx + ecx + 2], bl    ;val 3
       push eax
       mov eax, [ebp + 8]   ;text
       xor ebx, ebx
       mov word bx, [eax + ecx + 1]
       shl bx, 7
       shr bx, 11
       pop eax
       inc eax
       mov byte [edx + ecx + 3], bl    ;val 4
       push eax
       mov eax, [ebp + 8]   ;text
       xor ebx, ebx
       mov word bx, [eax + ecx + 2]
       shl bx, 4
       shr bx, 11 
       pop eax
       inc eax
       mov byte [edx + ecx + 4], bl    ;val 5
       push eax
       mov eax, [ebp + 8]   ;text
       xor ebx, ebx
       mov byte bl, [eax + ecx + 3]
       shl bl, 1
       shr bl, 3
       pop eax
       inc eax
       mov byte [edx + ecx + 5], bl    ;val 6
       push eax
       mov eax, [ebp + 8]   ;text
       xor ebx, ebx
       mov word bx, [eax + ecx + 3]
       shl bx, 6
       shr bx, 11
       pop eax
       inc eax
       mov byte [edx + ecx + 6], bl     ;val 7
       push eax
       mov eax, [ebp + 8]   ;text
       xor ebx, ebx
       mov byte bl, [eax + ecx + 4]
       shl bl, 3
       shr bl, 3
       pop eax
       inc eax
       mov byte [edx + ecx + 7], bl     ;val 8
       push eax
       mov eax, [ebp + 8]   ;text
       add ecx, 5
       jmp convert_5_bytes
       
       push ecx
       mov byte [edx + ecx + 1], 0x00
       xor ebx, ebx
get_chars:
       mov byte bl, [edx + ecx]
       cmp bl, 26
       jl to_char
       add bl, 24
put_in_string:     
       mov byte [edx + ecx], bl
       dec ecx
       cmp ecx, -1
       je return  
       jmp get_chars
               
to_char:
       add bl, 65
       jmp put_in_string  
              
return:      
       leave
	ret

bruteforce_singlebyte_xor:
	; TODO TASK 5
       push ebp
       mov ebp, esp
       mov ecx, [ebp + 8]   ;text
       xor eax, eax
       mov al, 0   ;cheia                ;pornesc cu cheia 00000000 si incrementez spre maximul 11111111
                                         ;pana gasesc valoarea care decripteaza corect sirul dat
       mov ebx, 0
find_force:
       mov ah, 0
       mov byte ah, [ecx + ebx]          ;citesc cate un octet
       cmp ah, 0x00                      ;daca am ajuns la sfarsitul sirului si nu am gasit secventa force, inseamna ca nu am gasit inca cheia,
                                         ;deci o incerc pe urmatoarea
       je inc_key
       xor ah, al
       cmp ah, 'f'                       ;daca gasesc litera f, voi verifica daca este urmata de o
       je find_o
       inc ebx
       jmp find_force                    ;daca nu gasesc litera f, o caut pe urmatoarea pozitie din sir

find_o:
      inc ebx
      mov byte ah, [ecx + ebx]
      xor ah, al
      cmp ah, 'o'                        ;daca gasesc litera o, voi verifica daca este urmata de r
      je find_r
      jmp find_force                     ;daca nu este urmata de o, caut litera f pe urmatoarea pozitie din sir
      
find_r:
      inc ebx
      mov byte ah, [ecx + ebx]
      xor ah, al
      cmp ah, 'r'
      je find_c                          ;daca gasesc litera r, voi verifica daca este urmata de c
      sub ebx, 1
      jmp find_force                     ;daca nu este urmata de r, caut litera f pe urmatoarea pozitie din sir
      
find_c:
      inc ebx
      mov byte ah, [ecx + ebx]
      xor ah, al
      cmp ah, 'c'
      je find_e                          ;daca gasesc litera c, voi verifica daca este urmata de e
      sub ebx, 2
      jmp find_force                     ;daca nu este urmata de c, caut litera f pe urmatoarea pozitie din sir
      
find_e:
      inc ebx
      mov byte ah, [ecx + ebx]
      xor ah, al
      cmp ah, 'e'
      je key_found                       ;daca gasesc si litera e, inseamna ca am gasit intreaga secventa(force),
                                         ;deci am gasit cheia corecta si trec la decriptarea sirului
      sub ebx, 3
      jmp find_force                     ;daca nu este urmata de e, caut litera f pe urmatoarea pozitie din sir
      
key_found:
      xor ebx, ebx
continue_xor:
      mov byte ah, [ecx + ebx]
      cmp ah, 0x00
      je end
      xor ah, al                         ;decriptez cu xor intre cheie si fiecare octet al sirului
      mov byte [ecx + ebx], ah
      inc ebx
      jmp continue_xor
      
inc_key:
      cmp al, 255                        ;daca cheia are deja valoarea maxima, inseamna ca secventa
                                         ;force nu a fost gasita cu nicio cheie si se iese din functie
      je end
      inc al                             ;altfel se incrementeaza cheia
      mov ebx, 0                         ;se reseteaza indexul pozitiei din sir
      jmp find_force
      
      
end:
       mov ah, 0
       leave
	ret

decode_vigenere:
	; TODO TASK 6
       push ebp
       mov ebp, esp
       
       mov ebx, [ebp + 12] ; cheie
       push ebx
       call strlen                       ;aflu lungimea cheii
       add esp, 4
       push eax                          ;tin lungimea cheii pe stiva
       
       mov eax, [ebp + 8] ; text
       mov ebx, [ebp + 12] ; cheie
       mov cl, 0                         ;cate caractere de orice fel am citit din sir
       mov ch, 0                         ;cu a cata litera din cheie trebuie sa fac shift-area
       
decript:
       xor ebx, ebx
       mov bl, cl
       mov eax, [ebp + 8] ; text
       mov byte dl, [eax + ebx]          ;citesc cate un octet din sir
       cmp dl, 0x00
       je finish                         ;verific daca am ajuns la finalul sirului pentru a iesi din functie
       inc cl
       cmp dl, 'a'                       ;daca caracterul nu este litera citesc urmatorul caracter(il incrementez doar pe cl)
       jl decript
       xor eax, eax
       pop eax                           ;scoatem lungimea cheii de pe stiva
       xor ebx, ebx
       mov bl, ch
       cmp ebx, eax                      ;daca am ajuns la ultima litera a cheii, trebuie sa resetez contorul ch,
                                         ;altfel il incrementez
       je reset_ch
       inc ch
       push eax
roll:
       xor ebx, ebx
       mov ebx, [ebp + 12] ; cheie       
       xor eax, eax
       mov al, ch
       dec al
       mov byte dh, [ebx + eax]          ;stabilesc octetul cheii care imi indica shift-area necesara(cu ajutorul lui ch)
       sub dh, 'a'                       ;calculez shift-area care va trebui efectuata
       sub dl, dh                        ;o efectuez
       cmp dl, 'a'                       ;daca se scade prea mult, se iese din intervalul literelor si trebuie corectat
                                         ;prin numararea diferentei incepand de la z spre a
       jl reposition_to_a_z
       mov eax, [ebp + 8] ; text
put_result:
       xor ebx, ebx
       mov bl, cl
       dec bl
       mov eax, [ebp + 8] ; text
       mov byte [eax + ebx], dl          ;pun rezultatul inapoi in sir, apoi trec la citirea umatorului caracter
       jmp decript
       
       
reset_ch:      
       mov ch, 1                         ;dupa ce am parcurs toata cheia, revin la inceputul acesteia
       push eax
       jmp roll

reposition_to_a_z:
       add dl, dh                        ;se revine la caracterul din string
       xor eax, eax
       mov ah, 26                        ;nr de litere din alfabet
       sub ah, dh    
       add dl, ah                        ;in loc sa scad din caracter un numar x, adaugam 26-x(pentru a realiza o shift-are circulara)
       jmp put_result
finish:      
       leave
	ret

main:
	push ebp
	mov ebp, esp
	sub esp, 2300

	; test argc
	mov eax, [ebp + 8]
	cmp eax, 2
	jne exit_bad_arg

	; get task no
	mov ebx, [ebp + 12]
	mov eax, [ebx + 4]
	xor ebx, ebx
	mov bl, [eax]
	sub ebx, '0'
	push ebx

	; verify if task no is in range
	cmp ebx, 1
	jb exit_bad_arg
	cmp ebx, 6
	ja exit_bad_arg

	; create the filename
	lea ecx, [filename + 7]
	add bl, '0'
	mov byte [ecx], bl

	; fd = open("./input{i}.dat", O_RDONLY):
	mov eax, 5
	mov ebx, filename
	xor ecx, ecx
	xor edx, edx
	int 0x80
	cmp eax, 0
	jl exit_no_input

	; read(fd, ebp - 2300, inputlen):
	mov ebx, eax
	mov eax, 3
	lea ecx, [ebp-2300]
	mov edx, [inputlen]
	int 0x80
	cmp eax, 0
	jl exit_cannot_read

	; close(fd):
	mov eax, 6
	int 0x80

	; all input{i}.dat contents are now in ecx (address on stack)
	pop eax
	cmp eax, 1
	je task1
	cmp eax, 2
	je task2
	cmp eax, 3
	je task3
	cmp eax, 4
	je task4
	cmp eax, 5
	je task5
	cmp eax, 6
	je task6
	jmp task_done

task1:
	; TASK 1: Simple XOR between two byte streams

	; TODO TASK 1: find the address for the string and the key
       xor ebx, ebx
       ;push ecx
       mov ebx, ecx
       mov ecx, 0
loop_start:                                  ;iterez pentru a gasi sfarsitul sirului
       mov eax, 0
       mov byte al, [ebx + ecx]
       cmp al, 0x00
       je save_key_adr
       inc ecx
       jmp loop_start

save_key_adr:                                ;cand il gasesc, incrementez, apoi salvez adresa, aceasta indicand inceputul cheii
       inc ecx
       xor edx, edx
       lea edx, [ebx + ecx]      
       
       
	; TODO TASK 1: call the xor_strings function
   
       push edx ; adresa cheii              ;pun argumentele pe stiva
       push ebx ; adresa textului
       call xor_strings            
       add esp, 8
       
       mov ecx, eax
	push ecx
	call puts                            ;printez sirul rezultat
	add esp, 4

	jmp task_done

task2:
	; TASK 2: Rolling XOR

	; TODO TASK 2: call the rolling_xor function
       push ecx                             ;pun argumentul pe stiva(sirul criptat)
       call rolling_xor                     ;apelez functia de decriptare
       add esp, 4
       
       mov ecx, eax
	push ecx
	call puts
	add esp, 4

	jmp task_done

task3:
	; TASK 3: XORing strings represented as hex strings

	; TODO TASK 1: find the addresses of both strings
       xor ebx, ebx
       mov ebx, ecx
       mov ecx, 0
loop_start2:                                ;iterez pentru a gasi sfarsitul sirului
       mov eax, 0
       mov byte al, [ebx + ecx]
       cmp al, 0x00
       je save_key_adr2
       inc ecx
       jmp loop_start2

save_key_adr2:                              ;cand il gasesc, incrementez, apoi salvez adresa, aceasta indicand inceputul cheii
       inc ecx
       xor edx, edx
       lea edx, [ebx + ecx] 
	; TODO TASK 1: call the xor_hex_strings function

       push edx ; adresa cheii             ;pun argumentele pe stiva
       push ebx ; adresa textului
       call xor_hex_strings
       add esp, 8
       
       mov ecx, eax
	push ecx                            ;printez sirul reultat
	call puts
	add esp, 4

	jmp task_done

task4:
	; TASK 4: decoding a base32-encoded string

	; TODO TASK 4: call the base32decode function
	push ecx                            ;pun parametrul pe stiva, apoi apelez functia
       call base32decode
       pop ecx
       
       mov ecx, edx
	push ecx
	call puts                           
	pop ecx
	
	jmp task_done

task5:
	; TASK 5: Find the single-byte key used in a XOR encoding

	; TODO TASK 5: call the bruteforce_singlebyte_xor function


	push ecx                           ;pun parametrul pe stiva, apoi apelez functia
	call bruteforce_singlebyte_xor
	pop ecx

       push eax                           ;salvez valoarea lui eax pe stiva deoarece va fi alterata de puts
       
	push ecx                           ;printez sirul rezultat
	call puts
	pop ecx

       pop eax                            ;preiau cheia
	push eax                  
	push fmtstr
	call printf                        ;printez cheia
	add esp, 8

	jmp task_done

task6:
	; TASK 6: decode Vignere cipher

	; TODO TASK 6: find the addresses for the input string and key
	; TODO TASK 6: call the decode_vigenere function

	push ecx                           ;aflu adresa cheii              
	call strlen
	pop ecx

	add eax, ecx
	inc eax

	push eax       ;cheia              ;pun parametrul pe stiva, apoi apelez functia
	push ecx       ;textul criptat 
	call decode_vigenere
	pop ecx
	add esp, 4

	push ecx
	call puts                          ;printez sirul rezultat
	add esp, 4

task_done:
	xor eax, eax
	jmp exit

exit_bad_arg:
	mov ebx, [ebp + 12]
	mov ecx , [ebx]
	push ecx
	push usage
	call printf
	add esp, 8
	jmp exit

exit_no_input:
	push filename
	push error_no_file
	call printf
	add esp, 8
	jmp exit

exit_cannot_read:
	push filename
	push error_cannot_read
	call printf
	add esp, 8
	jmp exit

exit:
	mov esp, ebp
	pop ebp
	ret
