#INCLUDE "PROTHEUS.CH"        
#INCLUDE "Directry.ch"
#include "fileio.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPLIBSPL ºAutor  ³Microsiga           º Data ³  12/26/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipLibSpl()
Local nOpc := 0       
Local aDir := {}    
Local nH   := 0	     
Local cLinha   := ""
Local cNomArq  := ""
Local cCaminho := ""
Local nI
nOpc := Aviso("Escolha","Qual Spool deseja liberar?",{"Mezanino","Terreo","PackList"},1)       

If nOpc > 0 
	Do Case
		Case nOpc == 1                                                        
			//aDir := DIRECTORY("\impter\zebra\*.0000", "D")
			aDir := DIRECTORY("\impter\zebra\expedicao mezanino\*.0000", "D")
			cCaminho := "\impter\zebra\expedicao mezanino\"
		Case nOpc == 2
			aDir := DIRECTORY("\impter\zebra\expedicao terreo\*.0000", "D")
			cCaminho := "\impter\zebra\expedicao terreo\"
		Case nOpc == 3
			aDir := DIRECTORY("\impter\zebra\packlist\*.0000", "D")
			cCaminho := "\impter\zebra\packlist\"
	End Case           	

	If Len(aDir)>0
		For nI:=1 to Len(aDir)
			cNomArq := cCaminho + aDir[nI,1]
			nH := FOpen(cNomArq)	

			If nH > 0                         			
				FT_FUse(cNomArq)
				FT_FGOTOP()           
				If !FT_FEof()  
					cLinha := FT_FReadLn()        
					If nOpc == 3
						cLinha := Left(cLinha,21)+"PACKLIST       Vol: 9999999999OK        9                    "
					Else
						cLinha := Left(cLinha,21)+"VOLUME         OS/PROD: 999999OK        9                    "
					EndIf
					FT_FUse()
					FClose(nH)
					FErase(cNomArq)
					nH := FCreate(Upper(cNomArq))    
					If nH > 0
						FWrite(nH,cLinha)         
					EndIf
					FClose(nH)
				EndIf                     
			EndIf	
			If Aviso("Atenção","O Spool foi liberado?",{"Sim","Não"},1)==1
				Exit
			EndIf
		Next nI
	Else 
		Aviso("Atenção","Não foram encontrados arquivos travando este spool",{"Ok"},1)
	EndIf
EndIf

Return 
