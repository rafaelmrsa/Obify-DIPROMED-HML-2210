#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'RWMAKE.CH'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPINVENT �Autor  �Microsiga           � Data �  01/17/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DipOpeEnd()
Local aAreaCBA  := CBA->(GetArea())
Local cSQL 		:= ""                                            
Local aLogSB2 	:= {}
Local nPos		:= 0
Local cPerg     := "DIPOPEEN"
Local nLin		:= 0
Local nI 		:= 0
Local lFlag		:= .F.
Local nPerc1 	:= 0	
Local nPerc2 	:= 0	
Local lTudoOk	:= .F.
Local aOk    	:= {}
Local aDiverg	:= {}
Local lPriCon 	:= .T.            
Local lTudoOk 	:= .T.      
Local nCntPro 	:= 0
Local nCntOk	:= 0
Local nCntOk1	:= 0
Local nCntOk2	:= 0
Local nCntDiv 	:= 0
Local nCntDiv1 	:= 0
Local nCntDiv2 	:= 0
Local aPriCon 	:= {}  
Local aRecCBA  	:= {}
Local aRecCBC  	:= {}             
Local aTudoOk	:= {}
Local dDtInvet  := StoD("")                         
Local aDadosCab := {}

PRIVATE nBar	:= 0
PRIVATE oPrint  := TMSPrinter():New("Operadores X Endere�os")
PRIVATE titulo 	:= "Operadores X Endere�os"                      
PRIVATE oFont09 := TFont():New("Arial",9,09,.T.,.F.,5,.T.,5,.T.,.F.)
PRIVATE oFont10 := TFont():New("Arial",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
PRIVATE oFont12 := TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
PRIVATE oFont12n:= TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
PRIVATE oFont15n:= TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
PRIVATE oFont28n:= TFont():New("Arial",9,28,.T.,.T.,5,.T.,5,.T.,.F.)

If !(oPrint:IsPrinterActive())
	oPrint:Setup()
	Return (.F.)
EndIf

oPrint:SetPortrait()

AjustaSX1(cPerg)

If !Pergunte(cPerg)
	Return .F.
EndIf

dData		:= mv_par01
cTipo		:= mv_par02
cOpeDe		:= mv_par03
cOpeAte	    := mv_par04

//SELECT CBA_XCONT1, COUNT(CBA_XCONT1) FROM CBA010 WHERE CBA_DATA = '20130125' AND CBA_CONTR = 1 AND CBA_STATUS > '3' AND D_E_L_E_T_ = ' ' GROUP BY CBA_XCONT1

cSQL := " SELECT "
cSQL += " 	A.CBA_XCONT1 OPE, CB1_NOME NOME, COUNT(A.CBA_XCONT1) QTD1, COUNT(B.CBA_XCONT1) QTD2 "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("CB1")+", "+RetSQLName("CBA")+" A "
cSQL += " 		LEFT JOIN "
cSQL += 			RetSQLName("CBA")+" B "
cSQL += " 			ON "
cSQL += " 				A.CBA_FILIAL = B.CBA_FILIAL AND "
cSQL += " 				A.CBA_DATA 	 = B.CBA_DATA AND "
cSQL += " 				A.CBA_CODINV = B.CBA_CODINV AND "
cSQL += " 				A.CBA_LOCALI = B.CBA_LOCALI AND	"
If mv_par02==1
	cSQL += " 			B.CBA_CONTR > 0 AND "
	cSQL += " 			B.CBA_STATUS > '2' AND "
Else 
	cSQL += " 			B.CBA_CONTR = 1 AND "
	cSQL += " 			B.CBA_STATUS > '2' AND "	
EndIf
cSQL += " 				B.D_E_L_E_T_ = ' ' "
cSQL += " 		WHERE "
If mv_par02==1
	cSQL += " 		A.CBA_XCONT1 = CB1_CODOPE AND "
Else 
	cSQL += " 		A.CBA_XCONT2 = CB1_CODOPE AND "	
EndIf
cSQL += " 			A.CBA_DATA = '"+DtoS(mv_par01)+"' AND "
If !Empty(mv_par03) .Or. !Empty(mv_par04)
	If mv_par02==1
		cSQL += " 	A.CBA_XCONT1 = '"+mv_par03+"' AND '"+mv_par04+"' AND "
	Else                                                                     
		cSQL += " 	A.CBA_XCONT2 = '"+mv_par03+"' AND '"+mv_par04+"' AND "
	EndIf
EndIf
cSQL += " 			A.D_E_L_E_T_ = ' ' AND "
cSQL += 			RetSQLName("CB1")+".D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY A.CBA_XCONT1, CB1_NOME "
cSQL += " ORDER BY CB1_NOME " 

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCBA",.T.,.T.)

TCSETFIELD("QRYCBA","QTD1","N",12,0)
TCSETFIELD("QRYCBA","QTD2","N",12,0)			

While !QRYCBA->(Eof())    
	                                                                      
	aAdd(aDadosCab, {QRYCBA->OPE,;
					QRYCBA->NOME,;
					QRYCBA->QTD1,;
					QRYCBA->QTD2,;
					((QRYCBA->QTD2*100)/QRYCBA->QTD1)} )
										
	                                                        

        
	QRYCBA->(dbSkip())
EndDo
QRYCBA->(dbCloseArea())                                                                                                             

aSort(aDadosCab,,,{|x,y| x[5]>y[5] })                    

For nI:=1 to Len (aDadosCab)
	ImpLin2(@nLin,aDadosCab[nI])    
Next nI

oPrint:EndPage()             

oPrint:Preview()

MS_FLUSH()                   

RestArea(aAreaCBA)

Return     
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPINV14  �Autor  �Microsiga           � Data �  04/22/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpLin2(nLin,aDadosCab)

	If nLin > 3200  
		oPrint:EndPage()    
		nLin := 0
		oPrint:StartPage()
	ElseIf nLin == 0
		oPrint:StartPage()
	EndIf
	

	If nLin==0
		nLin := InvtCab(nLin)		
	EndIf
	
	oPrint:Say(nLin,0100,aDadosCab[1] 												,oFont12)
	oPrint:Say(nLin,0300,PadR(aDadosCab[2],20)										,oFont12)
	oPrint:Say(nLin,0800,Transform(aDadosCab[3],"@E 9999")							,oFont12)
	oPrint:Say(nLin,1000,Transform(aDadosCab[4],"@E 9999")							,oFont12)
	oPrint:Say(nLin,1200,Transform((aDadosCab[4]*100/aDadosCab[3]),"@E 999.99")+"%"	,oFont12)
   	
	nLin+=50			
		
	If nLin > 3200  
		oPrint:EndPage()
		nLin := 0
		oPrint:StartPage()
	EndIf

Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPINVENT �Autor  �Microsiga           � Data �  01/17/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function InvtCab(nLin)              
DEFAULT nLin := 0

If nLin == 0
	nLin :=100
	oPrint:Line(nLin,0100,nLin,2200) 	

	nLin+=10	
	oPrint:Say(nLin,0800,"### OPERADORES X ENDERECOS ###"	   		,oFont15n)    //Codigo do produto
	nLin+=60
	
	oPrint:Line(nLin,0100,nLin,2200) 	
	nLin+=100		
EndIf

oPrint:Say(nLin,0100,"COD"			,oFont12n)
oPrint:Say(nLin,0300,"NOME" 		,oFont12n)

oPrint:Say(nLin,0800,"QTD"	   		,oFont12n)
oPrint:Say(nLin,1000,"CONC."		,oFont12n)

oPrint:Say(nLin,1200,"%"			,oFont12n)

nLin+=50
oPrint:Line(nLin,0100,nLin,2200) 
nLin+=10

Return nLIn
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPR099   �Autor  �Microsiga           � Data �  10/08/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AjustaSX1(cPerg)
Local aRegs 	:= {}
DEFAULT cPerg 	:= ""

dbSelectArea("SX1")
dbSetOrder(1)                                                                                                                                                                       

aAdd(aRegs,{cPerg,"01","Dt.Inventar.?","","","mv_ch1","D",08,0,0,"G","","MV_PAR01",""			 ,"","","","",""		,"","","","",""		,"","","","","","","","","","","","","",''		})
aAdd(aRegs,{cPerg,"02","Tipo	    ?","","","mv_ch2","N",01,0,0,"C","","MV_PAR02","Primeira"    ,"","","","","Segunda"	,"","","","",""		,"","","","","","","","","","","","","",''		})
aAdd(aRegs,{cPerg,"03","Operador De ?","","","mv_ch3","C",06,0,0,"G","","MV_PAR03",""			 ,"","","","",""		,"","","","",""		,"","","","","","","","","","","","","",'DIPCB1'})
aAdd(aRegs,{cPerg,"04","Operador Ate?","","","mv_ch4","C",06,0,0,"G","","MV_PAR04",""			 ,"","","","",""		,"","","","",""		,"","","","","","","","","","","","","",'DIPCB1'})

PlsVldPerg( aRegs )       

Return