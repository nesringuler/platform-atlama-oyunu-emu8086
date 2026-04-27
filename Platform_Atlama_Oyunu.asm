ORG 100h

.DATA

    p_x      DB 10
    p_y      DB 18
    old_p_y  DB 18

    s_x      DB 75
    b_x      DB 110

    j_state  DB 0
    skor     DB 0
    over_f   DB 0

    s_pass   DB 0
    b_pass   DB 0

    mbaslik DB 'PLATFORM ATLAMA OYUNU$'
    mbasla  DB 'BASLAMAK ICIN ENTERA BASINIZ$'
    mrestart DB 'TEKRAR BASLAMAK ICIN ENTERA BASIN$'
    en_yuksek_skor DB 0

.CODE

START:

    MOV AX, @DATA
    MOV DS, AX

    MOV AX, 0003h
    INT 10h

    MOV p_x, 10
    MOV p_y, 18
    MOV old_p_y, 18
    MOV s_x, 75
    MOV b_x, 110
    MOV j_state, 0
    MOV skor, 0
    MOV over_f, 0
    MOV s_pass, 0
    MOV b_pass, 0

BASLANGIC_TAMPON_TEMIZLE:

    MOV AH, 01h
    INT 16h
    JZ  BASLANGIC_EKRANI

    MOV AH, 00h
    INT 16h
    JMP BASLANGIC_TAMPON_TEMIZLE

BASLANGIC_EKRANI:

    MOV AX, 0B800h
    MOV ES, AX

    MOV DI, 1656
    LEA SI, mbaslik
    MOV AH, 0Bh

BASLIK_BAS:
    LODSB
    CMP AL, '$'
    JE  BASLA_YAZISI
    MOV ES:[DI], AL
    MOV ES:[DI+1], AH
    ADD DI, 2
    JMP BASLIK_BAS

BASLA_YAZISI:
    MOV DI, 1974
    LEA SI, mbasla
    MOV AH, 0Bh

BASLA_BAS:
    LODSB
    CMP AL, '$'
    JE  BEKLE_ENTER
    MOV ES:[DI], AL
    MOV ES:[DI+1], AH
    ADD DI, 2
    JMP BASLA_BAS

BEKLE_ENTER:

    MOV AH, 00h
    INT 16h
    CMP AL, 0Dh
    JNE BEKLE_ENTER

ENTER_SONRASI_TEMIZLE:

    MOV AH, 01h
    INT 16h
    JZ  OYUNU_BASLAT

    MOV AH, 00h
    INT 16h
    JMP ENTER_SONRASI_TEMIZLE

OYUNU_BASLAT:

    MOV p_x, 10
    MOV p_y, 18
    MOV old_p_y, 18
    MOV s_x, 75
    MOV b_x, 110
    MOV j_state, 0
    MOV skor, 0
    MOV over_f, 0
    MOV s_pass, 0
    MOV b_pass, 0

    MOV AX, 0003h
    INT 10h

    CALL ZEMIN_CIZ
    CALL SKOR_YAZ
    CALL EN_YUKSEK_SKOR_UST_YAZ
    CALL CIZIMLER

OYUN_BASLASIN:

ANA_DONGU:

    MOV CX, 0000h
    MOV DX, 0300h
    MOV AH, 86h
    INT 15h

    MOV AH, 01h
    INT 16h
    JZ  TUS_YOK

    MOV AH, 00h
    INT 16h
    CMP AL, 20h
    JNE TUS_YOK

    CMP j_state, 0
    JNE TUS_YOK
    MOV j_state, 1

TUS_YOK:
    MOV AL, p_y
    MOV old_p_y, AL

    CALL ZIPLAMA_KONTROL

    MOV AL, p_y
    CMP AL, old_p_y
    JE  KARAKTER_ESKI_SILME

    MOV DH, old_p_y
    MOV DL, p_x
    CALL IMLEC
    MOV AL, ' '
    CALL KARAKTER_BAS

KARAKTER_ESKI_SILME:

    CMP s_x, 79
    JA  S_ESKI_SILME
    MOV DH, 18
    MOV DL, s_x
    CALL IMLEC
    MOV AL, ' '
    CALL KARAKTER_BAS

S_ESKI_SILME:

    CMP b_x, 79
    JA  B_ESKI_SILME
    MOV DH, 18
    MOV DL, b_x
    CALL IMLEC
    MOV AL, ' '
    CALL KARAKTER_BAS

B_ESKI_SILME:

    SUB s_x, 2
    CMP s_x, 1
    JG  S_RESET_YOK   
    MOV AL, b_x
    ADD AL, 35
    MOV s_x, AL
    MOV s_pass, 0

S_RESET_YOK:                    

    SUB b_x, 2
    CMP b_x, 1
    JG  SKOR_KONTROL
    MOV AL, s_x
    ADD AL, 35
    MOV b_x, AL
    MOV b_pass, 0

SKOR_KONTROL:

    CALL SKOR_KONTROL_ET
    CALL CARPISMA_KONTROL

    CMP over_f, 1
    JE  GAME_OVER

    CALL ENGELLERI_CIZ

    MOV AL, p_y
    CMP AL, old_p_y
    JE  KARAKTER_CIZME

    MOV DH, p_y
    MOV DL, p_x
    CALL IMLEC
    MOV AL, 02h
    CALL KARAKTER_BAS

KARAKTER_CIZME:

    JMP ANA_DONGU

ZIPLAMA_KONTROL PROC
    CMP j_state, 1
    JE  YUKARI
    CMP j_state, 2
    JE  ASAGI
    RET

YUKARI:
    SUB p_y, 2
    CMP p_y, 14
    JNE Z_RET 
    MOV p_y, 14
    MOV j_state, 2
    RET

ASAGI:
    ADD p_y, 2
    CMP p_y, 18
    JNE Z_RET     
    MOV p_y, 18
    MOV j_state, 0

Z_RET:
    RET
ZIPLAMA_KONTROL ENDP

SKOR_KONTROL_ET PROC

    MOV AL, s_pass
    CMP AL, 1
    JE  IKINCI_ENGEL

    MOV AL, s_x
    CMP AL, p_x
    JAE IKINCI_ENGEL

    INC skor

    MOV AL, skor
    CMP AL, en_yuksek_skor
    JBE REKOR_GECME_1
    MOV en_yuksek_skor, AL

REKOR_GECME_1:

    CALL SKOR_YAZ
    CALL EN_YUKSEK_SKOR_UST_YAZ
    MOV s_pass, 1

IKINCI_ENGEL:

    MOV AL, b_pass
    CMP AL, 1
    JE  SK_RET

    MOV AL, b_x
    CMP AL, p_x
    JAE SK_RET

    INC skor

    MOV AL, skor
    CMP AL, en_yuksek_skor
    JBE REKOR_GECME_2
    MOV en_yuksek_skor, AL

REKOR_GECME_2:

    CALL SKOR_YAZ
    CALL EN_YUKSEK_SKOR_UST_YAZ
    MOV b_pass, 1

SK_RET:
    RET

SKOR_KONTROL_ET ENDP

CARPISMA_KONTROL PROC
    MOV AL, p_x
    CMP AL, s_x
    JE  Y_BAK  
    DEC AL
    CMP AL, s_x
    JE  Y_BAK
    
    MOV AL, p_x
    CMP AL, b_x
    JE  Y_BAK
    DEC AL
    CMP AL, b_x
    JE  Y_BAK
    RET

Y_BAK:
    MOV AL, p_y
    CMP AL, 18
    JNE CC_RET
    MOV over_f, 1

CC_RET:
    RET
CARPISMA_KONTROL ENDP

CIZIMLER PROC

    MOV DH, p_y
    MOV DL, p_x
    CALL IMLEC
    MOV AL, 02h
    CALL KARAKTER_BAS

    CMP s_x, 79
    JA  S_ATLA
    MOV DH, 18
    MOV DL, s_x
    CALL IMLEC
    MOV AL, 0DBh
    CALL KARAKTER_BAS

S_ATLA:

    CMP b_x, 79
    JA  B_ATLA
    MOV DH, 18
    MOV DL, b_x
    CALL IMLEC
    MOV AL, 0DBh
    CALL KARAKTER_BAS

B_ATLA:

    RET
CIZIMLER ENDP

ENGELLERI_CIZ PROC

    CMP s_x, 79
    JA  S_ATLA2
    MOV DH, 18
    MOV DL, s_x
    CALL IMLEC
    MOV AL, 0DBh
    CALL KARAKTER_BAS

S_ATLA2:

    CMP b_x, 79
    JA  B_ATLA2
    MOV DH, 18
    MOV DL, b_x
    CALL IMLEC
    MOV AL, 0DBh
    CALL KARAKTER_BAS

B_ATLA2:

    RET
ENGELLERI_CIZ ENDP

ZEMIN_CIZ PROC
    MOV DH, 19
    MOV DL, 0

Z_L:
    CALL IMLEC
    MOV AL, 0C4h
    CALL KARAKTER_BAS
    INC DL
    CMP DL, 80
    JB  Z_L
    RET

ZEMIN_CIZ ENDP

SKOR_YAZ PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH ES

    MOV AX, 0B800h
    MOV ES, AX
    MOV DI, 0

    MOV ES:[DI],   'S'
    MOV ES:[DI+1], 0Eh
    MOV ES:[DI+2], 'K'
    MOV ES:[DI+3], 0Eh
    MOV ES:[DI+4], 'O'
    MOV ES:[DI+5], 0Eh
    MOV ES:[DI+6], 'R'
    MOV ES:[DI+7], 0Eh
    MOV ES:[DI+8], ' '
    MOV ES:[DI+9], 0Eh
    MOV ES:[DI+10], ':'
    MOV ES:[DI+11], 0Eh
    MOV ES:[DI+12], ' '
    MOV ES:[DI+13], 0Eh

    XOR AX, AX
    MOV AL, skor
    MOV BL, 10
    DIV BL

    ADD AL, '0'
    MOV ES:[DI+14], AL
    MOV ES:[DI+15], 0Bh

    ADD AH, '0'
    MOV ES:[DI+16], AH
    MOV ES:[DI+17], 0Bh

    POP ES
    POP CX
    POP BX
    POP AX
    RET
SKOR_YAZ ENDP

FINAL_SKOR_YAZ PROC
    PUSH AX
    PUSH BX
    PUSH ES
    PUSH DI

    MOV AX, 0B800h
    MOV ES, AX
    MOV DI, 2130

    MOV ES:[DI],    'S'
    MOV ES:[DI+1],  0Eh
    MOV ES:[DI+2],  'K'
    MOV ES:[DI+3],  0Eh
    MOV ES:[DI+4],  'O'
    MOV ES:[DI+5],  0Eh
    MOV ES:[DI+6],  'R'
    MOV ES:[DI+7],  0Eh
    MOV ES:[DI+8],  ':'
    MOV ES:[DI+9],  0Eh
    MOV ES:[DI+10], ' '
    MOV ES:[DI+11], 0Eh

    XOR AX, AX
    MOV AL, skor
    MOV BL, 10
    DIV BL

    ADD AL, '0'
    MOV ES:[DI+12], AL
    MOV ES:[DI+13], 0Bh

    ADD AH, '0'
    MOV ES:[DI+14], AH
    MOV ES:[DI+15], 0Bh

    POP DI
    POP ES
    POP BX
    POP AX
    RET
FINAL_SKOR_YAZ ENDP

EN_YUKSEK_SKOR_YAZ PROC
    PUSH AX
    PUSH BX
    PUSH ES
    PUSH DI

    MOV AX, 0B800h
    MOV ES, AX
    MOV DI, 2290

    MOV ES:[DI],    'E'
    MOV ES:[DI+1],  0Ah
    MOV ES:[DI+2],  'N'
    MOV ES:[DI+3],  0Ah
    MOV ES:[DI+4],  ' '
    MOV ES:[DI+5],  0Ah
    MOV ES:[DI+6],  'Y'
    MOV ES:[DI+7],  0Ah
    MOV ES:[DI+8],  'U'
    MOV ES:[DI+9],  0Ah
    MOV ES:[DI+10], 'K'
    MOV ES:[DI+11], 0Ah
    MOV ES:[DI+12], 'S'
    MOV ES:[DI+13], 0Ah
    MOV ES:[DI+14], 'E'
    MOV ES:[DI+15], 0Ah
    MOV ES:[DI+16], 'K'
    MOV ES:[DI+17], 0Ah
    MOV ES:[DI+18], ':'
    MOV ES:[DI+19], 0Ah
    MOV ES:[DI+20], ' '
    MOV ES:[DI+21], 0Ah

    XOR AX, AX
    MOV AL, en_yuksek_skor
    MOV BL, 10
    DIV BL

    ADD AL, '0'
    MOV ES:[DI+22], AL
    MOV ES:[DI+23], 0Bh

    ADD AH, '0'
    MOV ES:[DI+24], AH
    MOV ES:[DI+25], 0Bh

    POP DI
    POP ES
    POP BX
    POP AX
    RET
EN_YUKSEK_SKOR_YAZ ENDP

EN_YUKSEK_SKOR_UST_YAZ PROC
    PUSH AX
    PUSH BX
    PUSH ES
    PUSH DI

    MOV AX, 0B800h
    MOV ES, AX
    MOV DI, 120

    MOV ES:[DI],    'E'
    MOV ES:[DI+1],  0Eh
    MOV ES:[DI+2],  'N'
    MOV ES:[DI+3],  0Eh
    MOV ES:[DI+4],  ' '
    MOV ES:[DI+5],  0Eh
    MOV ES:[DI+6],  'Y'
    MOV ES:[DI+7],  0Eh
    MOV ES:[DI+8],  'U'
    MOV ES:[DI+9],  0Eh
    MOV ES:[DI+10], 'K'
    MOV ES:[DI+11], 0Eh
    MOV ES:[DI+12], 'S'
    MOV ES:[DI+13], 0Eh
    MOV ES:[DI+14], 'E'
    MOV ES:[DI+15], 0Eh
    MOV ES:[DI+16], 'K'
    MOV ES:[DI+17], 0Eh
    MOV ES:[DI+18], ':'
    MOV ES:[DI+19], 0Eh
    MOV ES:[DI+20], ' '
    MOV ES:[DI+21], 0Eh

    XOR AX, AX
    MOV AL, en_yuksek_skor
    MOV BL, 10
    DIV BL

    ADD AL, '0'
    MOV ES:[DI+22], AL
    MOV ES:[DI+23], 0Bh

    ADD AH, '0'
    MOV ES:[DI+24], AH
    MOV ES:[DI+25], 0Bh

    POP DI
    POP ES
    POP BX
    POP AX
    RET
EN_YUKSEK_SKOR_UST_YAZ ENDP

IMLEC PROC
    MOV AH, 02h
    MOV BH, 0
    INT 10h
    RET
IMLEC ENDP

KARAKTER_BAS PROC
    MOV AH, 09h
    MOV BH, 0
    MOV BL, 0Fh
    MOV CX, 1
    INT 10h
    RET
KARAKTER_BAS ENDP

GAME_OVER:

    MOV AL, skor
    CMP AL, en_yuksek_skor
    JBE REKOR_GUNCELLEME_BITTI
    MOV en_yuksek_skor, AL

REKOR_GUNCELLEME_BITTI:

    MOV AX, 0003h
    INT 10h

    CALL FINAL_SKOR_YAZ
    CALL EN_YUKSEK_SKOR_YAZ

    MOV AX, 0B800h
    MOV ES, AX
    MOV DI, 2740

    LEA SI, mrestart
    MOV AH, 0Bh

MESAJ_BAS:
    LODSB
    CMP AL, '$'
    JE  BEKLE_RESTART
    MOV ES:[DI], AL
    MOV ES:[DI+1], AH
    ADD DI, 2
    JMP MESAJ_BAS

BEKLE_RESTART:
    MOV AH, 00h
    INT 16h
    CMP AL, 0Dh
    JNE BEKLE_RESTART

    JMP OYUNU_BASLAT

END START