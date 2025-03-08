	.MODEL	TINY

COM_8255	EQU	0273H		;8255���ƿ�
PA_8255		EQU	0270H
PB_8255		EQU	0271H
PC_8255		EQU	0272H
IO_273		EQU	0230H
PUBLIC	InitKeyDisplay, GetKey, GetKeyA, GetKeyB, GetBCDKey, DisPlay8, SCAN_KEY, DisPlay8A
PUBLIC	F1
	.STACK	100

	.DATA    
F1		DB	?
buffer          DB      8 DUP(?)					;8���ֽ���ʾ������
;keyoffset	DW	?						;��ֵ�������ʾ������λ��
SEG_TAB:	DB	0C0H,0F9H,0A4H,0B0H,099H,092H,082H,0F8H
		DB	080H,090H,088H,083H,0C6H,0A1H,086H,08EH 
		DB	0FFH,0BFH
SEG_TABA:	DB	03FH,006H,05BH,04FH,066H,06DH,07DH,007H
		DB	07FH,06FH,077H,07CH,039H,05EH,079H,071H 
		DB	000H,040H

	.CODE

GetKey		PROC	NEAR
		CMP	CX,0
		JZ	GetKey5
		CMP	CX,9
		JNB	GetKey5
		PUSH	AX
		PUSH	BX
		PUSH	DX
		PUSHF
		MOV	AX,CX
		CLC
		RCR	AX,1
		DEC	AX
		ADD	DI,AX
		STD
		MOV	AH,0
		CMP	F1,0
		JZ	GetKey1
		CALL	KeyScan
GetKey1:	CALL	initKD		;�����ʾ��������������һ����ֵ��ʾ��λ��
;		MOV	BX,keyoffset	;��һ����ֵ��ʾ��λ��
		CMP	F1,0
		JNZ	GetKey3
GetKey2:	CALL	KeyScan		;ɨ��
GetKey3:	NOT	AH
		PUSH	AX
		CMP	AH,0
		JZ	GetKey4
		ROR	AL,4
		MOV	ES:[DI],AL
		JMP	GetKey6
GetKey4:	OR	AL,ES:[DI]
		STOSB
GetKey6:	POP	AX
		MOV	[BX],AL
		DEC	BX
	 	LOOP	GetKey2
	 	POPF
	 	POP	DX
	 	POP	BX
	 	POP	AX
GetKey5:	RET
GetKey		ENDP

initKD		PROC	NEAR
		PUSHF
		PUSH	AX
;		PUSH	BX
		PUSH	CX
		PUSH	DI
		DEC	CX
		LEA	DI,buffer
		ADD	CX,DI
		MOV	BX,CX		;��һ����ֵ��ʾ��λ��
;		MOV	keyoffset,AX
;		MOV	BX,keyoffset	;
		MOV	CX,04H
		MOV	AX,1010H
		CLD
		REP	STOSW
		POP	DI
		POP	CX
;		POP	BX
		POP	AX
		POPF
		RET
initKD		ENDP

;��ֵ��AL��
KeyScan		PROC	NEAR
		CALL	SCAN_KEY
		JNB	KeyScan
		RET
KeyScan		ENDP

;CY =1,�м�,��ֵ��AL��;CY=0,û�а���
GetKeyA		PROC	NEAR
		CALL	SCAN_KEY
		RET
GetKeyA		ENDP

;��ֵ��AL��
GetKeyB		PROC	NEAR
		CALL	SCAN_KEY
		JNB	GetKeyB
		RET
GetKeyB		ENDP

;BCD��	;F1�Ƿ���Ҫ�������ʾ
GetBCDKey	PROC	NEAR
		CMP	CX,0
		JZ	GetBCDKey5
		CMP	CX,9
		JNB	GetBCDKey5
		PUSH	AX
		PUSH	BX
		PUSH	DX
		PUSHF
		MOV	AX,CX
		CLC
		RCR	AX,1
		DEC	AX
		ADD	DI,AX
		STD
		MOV	AH,0
		CMP	F1,0
		JZ	GetBCDKey1
		CALL	KeyScan
GetBCDKey1:	CALL	initKD		;�����ʾ��������������һ����ֵ��ʾ��λ��
;		MOV	BX,keyoffset	;��һ����ֵ��ʾ��λ��
		CMP	F1,0
		JNZ	GetBCDKey3
GetBCDKey2:	CALL	KeyScan		;ɨ��
GetBCDKey3:	CMP	AL,10
		JNB	GetBCDKey2
		NOT	AH
		PUSH	AX
		CMP	AH,0
		JZ	GetBCDKey4
		ROR	AL,4
		MOV	ES:[DI],AL
		JMP	GetBCDKey6
GetBCDKey4:	OR	AL,ES:[DI]
		STOSB
GetBCDKey6:	POP	AX
		MOV	[BX],AL
		DEC	BX
	 	LOOP	GetBCDKey2
	 	POPF
	 	POP	DX
	 	POP	BX
	 	POP	AX
GetBCDKey5:	RET
GetBCDKey	ENDP

InitKeyDisplay	PROC	NEAR
		PUSH	AX
		PUSH	DX
		MOV	DX,COM_8255
		MOV	AL,81H;9H
		OUT	DX,AL			;PA��PB�����PC����
		POP	DX
		POP	AX
		RET
InitKeyDisplay	ENDP
DisPlay8	PROC	NEAR
		PUSHF
		PUSH	ES
		PUSH	DI
		PUSH	SI
		PUSH	CX
		PUSH	DS
		POP	ES
		CLD
		LEA	DI,buffer
		MOV	CX,8
		REP	MOVSB
		POP	CX
		POP	SI
		POP	DI
		POP	ES
		POPF
		CALL	DIR
		RET
DisPlay8	ENDP
DIR		PROC	NEAR
		PUSHF
		PUSH	AX
		PUSH	BX
		PUSH	DX
		PUSH	SI
		CLD
		LEA	SI,buffer		;����ʾ��������ֵ
		MOV	AH,0FEH
		LEA	BX,SEG_TAB
LD0:		LODSB
		MOV	DX,AX
		AND	AL,7FH
		XLAT				;ȡ��ʾ����
		TEST	DL,80H			;���λ��1����Ҫ��ʾС����
		JZ	LD2
		AND	AL,7FH
LD2:		MOV	DX,PA_8255
		OUT	DX,AL			;������->8255 PA��
		INC	DX			;ɨ��ģʽ->8255 PB��
		MOV	AL,AH
		OUT	DX,AL
		CALL	DL1			;�ӳ�1ms
		MOV	DX,PB_8255
		MOV	AL,0FFH
		OUT	DX,AL
		TEST	AH,80H
		JZ	LD1
		ROL	AH,01H
		JMP	LD0
LD1:		POP	SI
		POP	DX
		POP	BX
		POP	AX
		POPF
		RET
DIR		ENDP

DisPlay8A	PROC	NEAR
		PUSHF
		PUSH	ES
		PUSH	DI
		PUSH	SI
		PUSH	CX
		PUSH	DS
		POP	ES
		CLD
		LEA	DI,buffer
		MOV	CX,8
		REP	MOVSB
		POP	CX
		POP	SI
		POP	DI
		POP	ES
		POPF
		CALL	DIR_IO
		RET
DisPlay8A	ENDP

DIR_IO		PROC	NEAR
		PUSHF
		PUSH	AX
		PUSH	BX
		PUSH	DX
		PUSH	SI
		CLD
		LEA	SI,buffer		;����ʾ��������ֵ
		MOV	AH,0FEH
		LEA	BX,SEG_TABA
LD00:		LODSB
		MOV	DX,AX
		AND	AL,7FH
		XLAT				;ȡ��ʾ����
		TEST	DL,80H			;���λ��1����Ҫ��ʾС����
		JZ	LD02
		OR	AL,80H
LD02:		MOV	DX,IO_273
		OUT	DX,AX			;������->��λ273, ɨ��ģʽ->��λ273
		CALL	DL1			;�ӳ�1ms
		PUSH	AX
		MOV	AH,0FFH
		OUT	DX,AX
		POP	AX
		TEST	AH,80H
		JZ	LD01
		ROL	AH,01H
		JMP	LD00
LD01:		POP	SI
		POP	DX
		POP	BX
		POP	AX
		POPF
		RET
DIR_IO		ENDP

DL1		PROC	NEAR			;�ӳ��ӳ���
		PUSH	CX
		MOV	CX,500
		LOOP	$
		POP	CX
		RET
DL1		ENDP

SCAN_KEY	PROC	NEAR
KEYI:		PUSH	BX
		PUSH	DX
LK:		CALL	AllKey			;���������ޱպϼ��ӳ���
		JNZ	LK1
		CALL	DIR			;������ʾ�ӳ���,�ӳ�6ms
		JMP	LKK
LK1:		CALL	DIR
		CALL	AllKey			;���������ޱպϼ��ӳ���
		JZ	LKK
		CALL	DIR
		CALL	AllKey			;���������ޱպϼ��ӳ���
		JZ	LKK
LK2:		MOV	BL,0FEH		;R2
		MOV	BH,0		;R4
LK4:		MOV	DX,PB_8255
		MOV	AL,BL
		OUT	DX,AL
		INC	DX
		IN	AL,DX
		TEST	AL,01H
		JNZ	LONE
		XOR	AL,AL			;0���м��պ�
		JMP	LKP			
LONE:		TEST	AL,02H
		JNZ	NEXT
		MOV	AL,08H			;1���м��պ�
LKP:		ADD	BH,AL
LK3:		CALL	DIR		;�ж��ͷŷ�
		CALL	AllKey
		JNZ	LK3
		MOV	AL,BH			;����->AL
		STC
		JMP	KND
NEXT:		INC	BH			;�м�������1
		TEST	BL,80H
		JZ	LKK			;���Ƿ���ɨ�����һ��
		ROL	BL,01H
		JMP	LK4
LKK:		CLC
KND:		POP	DX
		POP	BX
		RET
SCAN_KEY	ENDP

AllKey		PROC	NEAR
		MOV	DX,PB_8255
		XOR	AL,AL
		OUT	DX,AL			;ȫ"0"->ɨ���
		INC	DX
		IN	AL,DX			;����״̬
		NOT	AL
		AND	AL,03H			;ȡ�Ͷ�λ
		RET
AllKey		ENDP
				
		END
