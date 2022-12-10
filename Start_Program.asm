     ;;-------------- PROGRAM STARTS-------------------------
maindata:
   
    mov dx, offset msg1
    mov ah, 9
    int 21h
    
    
    mov ah, 1
    int 21h
    
    cmp al,31h
    jz colorBlue 
     
    cmp al,32h
    jz colorRed   
    
    cmp al,33h
    jz colorMagenta 
    
    cmp al,34h
    jz colorCyan     
    
    cmp al,35h
    jz colorGreen
    
    colorBlue:   
    mov player1,0c01h   
    jmp plot
    
    colorRed:  
    mov player1,0c04h   
    jmp plot
    
    colorMagenta:  
    mov player1,0c05h 
    jmp plot
    
    colorCyan:
    mov player1,0c0bh
    jmp plot 
    
    colorGreen:
    mov player1,0c02h
    jmp plot 
    
;SET BOUNDRY/PLAY AREA 
