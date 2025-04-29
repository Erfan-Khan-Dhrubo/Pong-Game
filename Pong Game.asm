.MODEL SMALL
.STACK 100H

.DATA

BALL_X DB 5          ; Starting X (column)
BALL_Y DB 2          ; Starting Y (row)

TEMP_TIME DB 0       ; comparing time vairable

WINDOW_WIDTH DB 4Fh
WINDOW_HEIGHT DB 18h


INCREMENT_POSITION_X DB 2
INCREMENT_POSITION_Y DB 2

.CODE

MAIN PROC

    MOV AX, @DATA
    MOV DS, AX
     
    
    MOV AH, 00h             ; set video mode.
    MOV AL, 03h             ; text mode (80 columns x 25 rows)
    INT 10h                 ; video service int
    
    
    TIME_LOOP:
    
        
        MOV AH, 2Ch         ; Get current time
        INT 21h
    
        CMP DL, TEMP_TIME   ; DL Hundredths of a second (0-99)
        JE TIME_LOOP        ; Compare current 1/100s with TEMP TIME
    
        
        MOV TEMP_TIME, DL   
    
        CALL ERASE_BALL    
        
        CALL MOVE_BALL
                 
    
        CALL DRAW_BALL     
    
        JMP TIME_LOOP     
                          
             
    ; exit
    MOV AX, 4C00h
    INT 21h

MAIN ENDP


;---------------------------------------------------

DRAW_BALL PROC

    MOV DH, BALL_Y     ; Set row (Y)
    MOV DL, BALL_X     ; Set column (X)
    MOV BH, 00h        ; Page number
    MOV AH, 02h        ; Set cursor position
    INT 10h

    MOV AH, 0Eh        ; Print character
    MOV AL, '*'        ; Ball shape
    MOV BH, 00h
    INT 10h

    RET
DRAW_BALL ENDP

;---------------------------------------------------

ERASE_BALL PROC

    MOV DH, BALL_Y
    MOV DL, BALL_X
    MOV BH, 00h
    MOV AH, 02h        ; Set cursor
    INT 10h

    MOV AH, 0Eh
    MOV AL, ' '        ; Print space to erase
    MOV BH, 00h
    INT 10h

    RET
ERASE_BALL ENDP

;---------------------------------------------------

MOVE_BALL PROC 
    
    MOV AL, INCREMENT_POSITION_X      ; changing x position
    ADD BALL_X, AL
    
    ; Check X collision
    CMP BALL_X, 0                     ; if ball_x < 0
    JL BOUNCE_X_LEFT
    MOV AL, WINDOW_WIDTH
    CMP BALL_X, AL                    ; if ball_x > window width
    JG BOUNCE_X_RIGHT

    
    MOV AL, INCREMENT_POSITION_Y      ; changing x position
    ADD BALL_Y, AL
    
    ; Check Y collision
    CMP BALL_Y, 0                     ; if ball_y < 0
    JL BOUNCE_Y_TOP
    MOV AL, WINDOW_HEIGHT
    CMP BALL_Y, AL                    ; if ball_y > window height
    JG BOUNCE_Y_BOTTOM

    RET


    ; Handle bounces:
    ; reverse the direction
    ; setting new position 
        
    BOUNCE_X_LEFT:
        NEG INCREMENT_POSITION_X
        MOV BALL_X, 0
        RET
    
    BOUNCE_X_RIGHT:
        NEG INCREMENT_POSITION_X
        MOV AL, WINDOW_WIDTH
        MOV BALL_X, AL
        RET
    
    BOUNCE_Y_TOP:
        NEG INCREMENT_POSITION_Y
        MOV BALL_Y, 0
        RET
    
    BOUNCE_Y_BOTTOM:
        NEG INCREMENT_POSITION_Y
        MOV AL, WINDOW_HEIGHT
        MOV BALL_Y, AL
        RET    

MOVE_BALL ENDP



END MAIN




