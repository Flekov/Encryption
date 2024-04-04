masm
model small
.data
handle dw 0
filename db 'opi.txt',0

text db 'For crypting press: 1', 0ah, 0dh, 'For decrypting press: 2', 0ah, 0dh, 'Exit: 3$'
entry_text db 0ah, 0dh, '>$'
endl db 0ah, 0dh, '$'
error_message1 db 0ah, 0dh, 'Incorrect input!$'
error_message2 db 0ah, 0dh, 'You cannot decrypt the original text!$'

two db 2
buffer db 200 (?)

.stack	256
.code
main:
	mov	ax,@data 
	mov	ds,ax 

	xor dx, dx
	xor bp, bp

;print instructions
	mov ah, 09h
	mov dx, offset text
	int 21h

	xor dx,dx
	
;open file
	mov	al,02h 
	mov dx, offset filename
	mov	ah,3dh 
	int	21h
	mov handle, ax

;read file
    mov ah, 3fh	
    mov bx, handle
    mov cx, 200
	xor dx,dx
	mov dx,offset buffer
    int 21h
	mov di,ax

;input
entry:
	mov ah, 09h
	xor dx,dx
	mov dx, offset entry_text
	int 21h

	mov ah, 01h
	int 21h

	cmp al, 31h
	je crypt

	cmp al, 32h
	je decrypt

	cmp al, 33h
	je exit_program

	mov ah,09h
	xor dx,dx
	mov dx, offset error_message1
	int 21h
	jmp entry

;crypting algorithm
crypt:
	xor ax,ax
	xor cx,cx
	mov cx,di
	mov si,0

crypt1:	
	mov al ,buffer[si]
	cmp bp,0
	je mul2

	cmp bp,1
	je plus4

	cmp bp,2
	je del2

	jmp plus1

mul2:
	mul two
	jmp crypt1_end

plus4:
	add al, 4
	jmp crypt1_end

del2:
	div two
	jmp	crypt1_end

plus1:
	inc al
	jmp crypt1_end
	
crypt1_end:
	mov buffer[si],al
	inc si
	loop crypt1

	inc bp
	jmp save

;closer exit
exit_program:
	jmp exit

;decrypting algorythm
decrypt:
	cmp bp, 0
	je error2

	xor ax,ax
	xor cx,cx
	mov cx,di
	mov si,0

decrypt1:	
	mov al ,buffer[si]
	cmp bp,1
	je div2

	cmp bp,2
	je minus4

	cmp bp,3
	je umn2

	jmp minus1

div2:
	div two
	jmp decrypt1_end

minus4:
	sub al,4 
	jmp decrypt1_end

umn2:
	mul two
	jmp decrypt1_end

minus1:
	dec al
	jmp decrypt1_end

decrypt1_end:
	mov buffer[si],al
	inc si
	loop decrypt1

	dec bp
	jmp save

;decrypting original text
error2:
	mov ah,09h
	xor dx,dx
	mov dx, offset error_message2
	int 21h

	jmp entry

;printing current
save: 
	mov ah, 09h
	xor dx,dx
	mov dx, offset endl
	int 21h

	xor cx,cx
	mov cx,di
	mov si,0
	mov ah,02h

saveLoop:
	mov dl,buffer[si]
	int 21h
	inc si
	loop saveLoop

	jmp entry

exit:
;save file
	;xor cx,cx
	;mov	cx,di
	;xor bx,bx
	;mov	bx,handle 
	;xor dx,dx
	;mov	dx,offset buffer
	;mov	ah,40h 
	;int	21h

;close file
    mov ah, 3eh
    mov bx, handle
    int 21h

	mov	ax,4c00h
	int	21h
end	main