#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TBICONN.CH" 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO19    �Autor  �Microsiga           � Data �  08/17/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DipNeo3M(aWork)      
             
If ValType(aWork)=="A"
	PREPARE ENVIRONMENT EMPRESA aWork[1] FILIAL aWork[2] FUNNAME "DipNeo3M"
	Conout("DipNeo3M - Inicio em: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+aWork[1]+" Fil:"+aWork[2])  
	
    //Clientes
	U_DipNCli3M()
	
	//Vendedores
	U_DipNVen3M()

	//Produtos
	U_DipNPro3M()	
	
	//Estoque
	U_DipNEst3M()		
             
	//Vendas
	U_DipNVend()			

	
	RESET ENVIRONMENT
	Conout("DipNeo3M - Fim em: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+aWork[1]+" Fil:"+aWork[2])		
EndIf	

Return    
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPNEO3M  �Autor  �Microsiga           � Data �  08/18/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DipRetCE(cString)
DEFAULT cString := ""

cString := StrTran(cString,"\"," ")
cString := StrTran(cString,"|"," ")
cString := StrTran(cString,","," ")
cString := StrTran(cString,"<"," ")
cString := StrTran(cString,"."," ")
cString := StrTran(cString,">"," ")
cString := StrTran(cString,";"," ")
cString := StrTran(cString,":"," ")
cString := StrTran(cString,"/"," ")
cString := StrTran(cString,"?"," ")
cString := StrTran(cString,"~"," ")
cString := StrTran(cString,"^"," ")
cString := StrTran(cString,"]"," ")
cString := StrTran(cString,"}"," ")
cString := StrTran(cString,"�"," ")
cString := StrTran(cString,"`"," ")
cString := StrTran(cString,"["," ")
cString := StrTran(cString,"{"," ")
cString := StrTran(cString,"'"," ")
cString := StrTran(cString,'"'," ")
cString := StrTran(cString,"!"," ")
cString := StrTran(cString,"@"," ")
cString := StrTran(cString,"#"," ")
cString := StrTran(cString,"$"," ")
cString := StrTran(cString,"%"," ")
cString := StrTran(cString,"�"," ")
cString := StrTran(cString,"&"," ")
cString := StrTran(cString,"*"," ")
cString := StrTran(cString,"("," ")
cString := StrTran(cString,")"," ")
cString := StrTran(cString,"_"," ")
cString := StrTran(cString,"-"," ")
cString := StrTran(cString,"+"," ")
cString := StrTran(cString,"�","A")
cString := StrTran(cString,"�","A")
cString := StrTran(cString,"�","A")
cString := StrTran(cString,"�","a")
cString := StrTran(cString,"�","a")
cString := StrTran(cString,"�","a")
cString := StrTran(cString,"�","E")
cString := StrTran(cString,"�","E")
cString := StrTran(cString,"�","e")
cString := StrTran(cString,"�","e")
cString := StrTran(cString,"�","I")
cString := StrTran(cString,"�","i")
cString := StrTran(cString,"�","O")
cString := StrTran(cString,"�","O")
cString := StrTran(cString,"�","o")
cString := StrTran(cString,"�","o")
cString := StrTran(cString,"�","U")
cString := StrTran(cString,"�","u")
cString := StrTran(cString,"�","C")
cString := StrTran(cString,"�","c")   

Return cString
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPNEO3M  �Autor  �Microsiga           � Data �  08/25/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DipPadDec(nDValor,nDipInt,nDipDec,lZerEsq)
Local cRetVal	:= ""
Local cValAux 	:= ""
Local nPos 		:= 0
DEFAULT nDValor := 0
DEFAULT nDipInt := 0   
DEFAULT nDipDec := 0
DEFAULT lZerEsq := .F.

//Melhoria para a fun��o - padronizar o tamanho total da cRetVal ao tamanho m�ximo passado na nDipInt 

If lZerEsq 
	cRet := StrZero(nDValor,nDipInt,nDipDec)
Else               
	cValAux := cValToChar(nDValor)  
	cRetVal := cValAux
	nPos := At(".",cValAux)
	If nPos == 0
		cRetVal := cValToChar(nDValor)+"."+Replicate("0",nDipDec)
	Else
		nLenDec := Len(SubStr(cValAux,nPos+1,Len(cValAux)))
		If nLenDec < nDipDec
			cRetVal := cValAux+Replicate("0",(nDipDec-nLenDec))
		ElseIf nLenDec > nDipDec
			cRetVal := SubStr(cValAux,1,Len(cValAux)-(nLenDec-nDipDec))		
		EndIf
	EndIf 
EndIf

Return cRetVal 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPNEO3M  �Autor  �Microsiga           � Data �  09/02/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DipSeqZT(cChave)
Local cRetSeq := StrZero(1,20)

SX5->(dbSetOrder(1))
If SX5->(dbSeek(xFilial("SX5")+"ZT"+cChave))
	cRetSeq := Soma1(AllTrim(SX5->X5_DESCRI))

	SX5->(RecLock("SX5",.F.))
		SX5->X5_DESCRI := cRetSeq
	SX5->(MsUnLock())
EndIf

Return cRetSeq   
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPNCLI3M �Autor  �Microsiga           � Data �  08/18/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DipGerN3M(aCabec,aDetal,cNomArq)
Local _nH 	   := 0
Local nI       := 0
Local cLinha   := ""
Local cDirDest := "\\172.27.72.246\Out\"
Local cDirOri  := "\ARQUIVOS_3M"

_nH := DipCriaRC(cNomArq,cDirOri)        

If _nH > 0                       
	If Len(aCabec)>0
		For nI:=1 to Len(aCabec[1])
			If nI>1
				cLinha += "|"
			EndIf
			cLinha += AllTrim(aCabec[1,nI])
		Next nI                       
		cLinha += CHR(13)+CHR(10)
		FWrite(_nH,cLinha)
			
		For nI:=1 to Len(aDetal) 
			cLinha := ""
			For nJ:=1 to Len(aDetal[nI])
				If nJ>1
					cLinha += "|"
				EndIf
				cLinha += AllTrim(aDetal[nI,nJ])
			Next nJ                         
			cLinha += CHR(13)+CHR(10)
			FWrite(_nH,cLinha)
		Next nI
		
		FClose(_nH)						
		
		//Aviso("Aten��o","Arquivo gerado com sucesso."+CHR(10)+CHR(13)+"C:\ARQUIVOS_3M\"+cNomArq,{"Ok"},2)
	EndIf      
EndIf

Return  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPNCLI3M �Autor  �Microsiga           � Data �  08/18/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DipCriaRC(cNomArq,cDir)
Local _nH 		:= 0 
DEFAULT cNomArq := ""
DEFAULT cDir 	:= ""
                   
cNomArq := cDir+"\"+cNomArq

Conout(cNomArq)

If !ExistDir(cDir)         
	If Makedir(cDir) <> 0
		Return
	Endif                  
Endif

If File(cNomArq)
	FErase(cNomArq)
EndIf

If !File(cNomArq)
	_nH := FCreate(cNomArq)
Endif 	  

Return _nH
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPNEO3M  �Autor  �Microsiga           � Data �  08/17/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AjustaSx1(cPerg)
Local aRegs 	:= {}
DEFAULT cPerg 	:= ""

dbSelectArea("SX1")
dbSetOrder(1)

aAdd(aRegs,{cPerg,"01","Tipo Arquivo?","","","mv_ch1","C",6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",'DIPRZU'})

PlsVldPerg( aRegs )

Return