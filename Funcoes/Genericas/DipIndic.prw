#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDipIndic	บAutor  ณMicrosiga           บ Data ณ  04/24/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipIndic(lDipMob)
Local cSQL 		:= ""             
Local aResFat	:= {}
Local aResPV	:= {}
Local aResFatHQ	:= {}
Local aResPVHQ	:= {}
Local aTela		:= GETSCREENRES()
Local cTitulo   := "Indicadores DIPROMED ("+DtoC(Date())+")"
Local nAux  	:= 0
Local _nVlrMeta := 0
Local _nVlrMPar := 0
Local _nVlrMPub := 0
Local _nVlrMRep := 0
Local _nVlrMTel := 0
Local _nVlrMHQ  := 0
Local nV := 0

//Local aTopFat 	:={}
Local nC        := 0
Private _nTel   := 0
Private _nPub   := 0
Private _nPar   := 0
Private _nRep   := 0
Private _nTot   := 0
Private _nTotH  := 0
Private _nTotA  := 0
Private _nTelH  := 0
Private _nPubH  := 0
Private _nParH  := 0
Private _nRepH  := 0
Private _nTelA  := 0
Private _nPubA  := 0
Private _nParA  := 0
Private _nRepA  := 0
Private _nTotHQ := 0
Private _nTotHHQ:= 0
Private _nTotAHQ:= 0
Private aFornec := {}

Private oFont17  := TFont():New("Arial",,IIf(lDipMob, -6,-17),.T.)					
Private oFont17n := TFont():New("Arial",,IIf(lDipMob, -8,-17),.T.,.T.)

Private oFont20  := TFont():New("Arial",,IIf(lDipMob,-10,-20),.T.)    
Private oFont20i := TFont():New("Arial",,IIf(lDipMob,-10,-20),.T.,.T.,,,,,,.T.)
Private oFont20n := TFont():New("Arial",,IIf(lDipMob,-10,-20),.T.,.T.)
Private oFont30n := TFont():New("Arial",,IIf(lDipMob,-15,-30),.T.,.T.)
     
nAux  := Int(((aTela[1]-50)/2))

_nVlrMeta := DipCalMet("000001")           
_nVlrMPar := DipCalMet("000003")           
_nVlrMPub := DipCalMet("000004")           
_nVlrMRep := DipCalMet("000005")           
_nVlrMTel := DipCalMet("000002")           
_nVlrMHQ  := DipCalMet("000001","040")           

ProcRegua(100)

DEFINE MSDIALOG oDlg TITLE "Indicadores DIPROMED - ฺltima atualiza็ใo: "+DtoC(Date())+" เs "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2) FROM 0,0 TO IIf(lDipMob,2560,aTela[2]),IIf(lDipMob,1440,aTela[1]) COLORS 0,0 PIXEL
nLin := 5                 

If lDipMob
	@ nLin,180 say cTitulo font oFont30n COLOR CLR_WHITE Pixel   
	@ nLin+10,247 say "versใo beta - MOBILE" font oFont16 COLOR CLR_WHITE Pixel   
Else                                                             
	@ nLin,200 say cTitulo font oFont20n COLOR CLR_WHITE Pixel   
EndIf

//______________________________________________________________________________
//                                           		 	                        |
//				F A T U R A M E N T O - DIPROMED								|
//______________________________________________________________________________|
//

aResFat := fQuery01("010")
aResPV  := fQuery03("010") 

nLin+=IIf(lDipMob,15,25)
@ nLin+4,005 say "PREV. DE FATURAM."			 font oFont17n COLOR CLR_HRED Pixel

nCol := 113  
@ nLin+4,nCol	 	say "APO - " 																	font oFont17n COLOR CLR_HRED Pixel
@ nLin+4,nCol+28	say TransForm(((aResFat[1]+aResPV[1])*100)/(aResFat[5]+aResPV[5]),"@E 999.99")+" %"	font oFont17 COLOR CLR_WHITE Pixel

nCol+=65
@ nLin+4,nCol 		say "LIC - " 																	font oFont17n COLOR CLR_HRED Pixel
@ nLin+4,nCol+28 	say TransForm(((aResFat[2]+aResPV[2])*100)/(aResFat[5]+aResPV[5]),"@E 999.99")+" %" font oFont17 COLOR CLR_WHITE Pixel

nCol+=65
@ nLin+4,nCol 		say "TEL - " 																	font oFont17n COLOR CLR_HRED Pixel
@ nLin+4,nCol+28 	say TransForm(((aResFat[4]+aResPV[4])*100)/(aResFat[5]+aResPV[5]),"@E 999.99")+" %" font oFont17 COLOR CLR_WHITE Pixel

nCol+=65
@ nLin+4  ,nCol 		say "TOTAL" font oFont17n COLOR CLR_YELLOW Pixel

nLin+=IIf(lDipMob,8,15)
@ nLin,005 To nLin+IIf(lDipMob,40,65),IIf(lDipMob,130,100) COLOR CLR_WHITE Pixel

@ nLin,110 To nLin+IIf(lDipMob,40,65),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel

//Colunas
@ nLin,IIf(lDipMob,079,175) To nLin+IIf(lDipMob,40,65),IIf(lDipMob,080,176) COLOR CLR_WHITE Pixel
@ nLin,IIf(lDipMob,079,240) To nLin+IIf(lDipMob,40,65),IIf(lDipMob,080,241) COLOR CLR_WHITE Pixel
@ nLin,IIf(lDipMob,079,305) To nLin+IIf(lDipMob,40,65),IIf(lDipMob,080,306) COLOR CLR_WHITE Pixel

//Linhas
@ nLin+IIf(lDipMob,07,13),005 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,100) COLOR CLR_WHITE Pixel
@ nLin+IIf(lDipMob,15,26),005 To nLin+IIf(lDipMob,16,27),IIf(lDipMob,130,100) COLOR CLR_WHITE Pixel
@ nLin+IIf(lDipMob,23,39),005 To nLin+IIf(lDipMob,24,40),IIf(lDipMob,130,100) COLOR CLR_WHITE Pixel
@ nLin+IIf(lDipMob,31,52),005 To nLin+IIf(lDipMob,32,53),IIf(lDipMob,130,100) COLOR CLR_WHITE Pixel

@ nLin+IIf(lDipMob,07,13),110 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel
@ nLin+IIf(lDipMob,15,26),110 To nLin+IIf(lDipMob,16,27),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel
@ nLin+IIf(lDipMob,23,39),110 To nLin+IIf(lDipMob,24,40),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel
@ nLin+IIf(lDipMob,31,52),110 To nLin+IIf(lDipMob,32,53),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel

nLin+=IIf(lDipMob,2,2)
@ nLin,008 say "Faturado Dia ("+Left(DtoC(DataValida(Date()-1,.F.)),5)+")"  			 font oFont17 COLOR CLR_WHITE Pixel

@ nLin,IIf(lDipMob,85,115) say PadL(TransForm(aResFat[12],"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel
@ nLin,IIf(lDipMob,85,180) say PadL(TransForm(aResFat[13],"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel
@ nLin,IIf(lDipMob,85,245) say PadL(TransForm(aResFat[15],"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel
@ nLin,IIf(lDipMob,85,310) say PadL(TransForm(aResFat[07],"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel

nLin+=IIf(lDipMob,8,13)
@ nLin,008 say "Faturado Hoje (1)"			 font oFont17 COLOR CLR_WHITE Pixel  //("+Left(DtoC(Date()),5)+")

@ nLin,IIf(lDipMob,85,115) say PadL(TransForm(aResFat[08],"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel
@ nLin,IIf(lDipMob,85,180) say PadL(TransForm(aResFat[09],"@E 999,999,999.99"),15) SIZE 80,10 font oFont17 COLOR CLR_WHITE Pixel 
@ nLin,IIf(lDipMob,85,245) say PadL(TransForm(aResFat[11],"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel
@ nLin,IIf(lDipMob,85,310) say PadL(TransForm(aResFat[06],"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel

nLin+=IIf(lDipMob,8,13)
@ nLin,008 say "P.V. Liberados (2)" 					 font oFont17 COLOR CLR_WHITE Pixel

@ nLin,IIf(lDipMob,85,115) say PadL(TransForm(aResPV[1],"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel
@ nLin,IIf(lDipMob,85,180) say PadL(TransForm(aResPV[2],"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel
@ nLin,IIf(lDipMob,85,245) say PadL(TransForm(aResPV[4],"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel
@ nLin,IIf(lDipMob,85,310) say PadL(TransForm(aResPV[5],"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel

nLin+=IIf(lDipMob,8,13)
@ nLin,008 say "Previsto (1+2)"					 		font oFont17n COLOR CLR_WHITE Pixel

@ nLin ,IIf(lDipMob,85,115) say PadL(TransForm(aResFat[08]+aResPV[1],"@E 999,999,999.99"),15) font oFont17n COLOR CLR_WHITE Pixel
@ nLin ,IIf(lDipMob,85,180) say PadL(TransForm(aResFat[09]+aResPV[2],"@E 999,999,999.99"),15) font oFont17n COLOR CLR_WHITE Pixel
@ nLin ,IIf(lDipMob,85,245) say PadL(TransForm(aResFat[11]+aResPV[4],"@E 999,999,999.99"),15) font oFont17n COLOR CLR_WHITE Pixel
@ nLin ,IIf(lDipMob,85,310) say PadL(TransForm(aResFat[06]+aResPV[5],"@E 999,999,999.99"),15) font oFont17n COLOR CLR_WHITE Pixel

nLin+=IIf(lDipMob,8,13)
@ nLin,008 say "Total Fat.+Previsto" 					 font oFont17n COLOR CLR_YELLOW Pixel

@ nLin ,IIf(lDipMob,85,115) say PadL(TransForm(aResFat[1]+aResPV[1],"@E 999,999,999.99"),15) font oFont17n COLOR CLR_YELLOW Pixel
@ nLin ,IIf(lDipMob,85,180) say PadL(TransForm(aResFat[2]+aResPV[2],"@E 999,999,999.99"),15) font oFont17n COLOR CLR_YELLOW Pixel
@ nLin ,IIf(lDipMob,85,245) say PadL(TransForm(aResFat[4]+aResPV[4],"@E 999,999,999.99"),15) font oFont17n COLOR CLR_YELLOW Pixel
@ nLin ,IIf(lDipMob,85,310) say PadL(TransForm(aResFat[5]+aResPV[5],"@E 999,999,999.99"),15) font oFont17n COLOR CLR_YELLOW Pixel

//______________________________________________________________________________
//                                           		 	                        |
//						M E T A - DIPROMED										|
//______________________________________________________________________________|
//

nLin+=IIf(lDipMob,15,13)
@ nLin+4,005 say "INDIC. DE META"					 font oFont17n COLOR CLR_HRED Pixel

nCol := 113  
@ nLin+4,nCol	 	say "APO - " 														 font oFont17n COLOR CLR_HRED Pixel
@ nLin+4,nCol+28 	say TransForm((((aResFat[1]+aResPV[1])*100)/_nVlrMPar),"@E 999.99")+" %" font oFont17 COLOR CLR_WHITE Pixel

nCol +=65
@ nLin+4,nCol 		say "LIC - " 														 font oFont17n COLOR CLR_HRED Pixel
@ nLin+4,nCol+28 	say TransForm((((aResFat[2]+aResPV[2])*100)/_nVlrMPub),"@E 999.99")+" %" font oFont17 COLOR CLR_WHITE Pixel

nCol+=65
@ nLin+4,nCol 		say "TEL - " 														 font oFont17n COLOR CLR_HRED Pixel
@ nLin+4,nCol+28 	say TransForm((((aResFat[4]+aResPV[4])*100)/_nVlrMTel),"@E 999.99")+"%"  font oFont17 COLOR CLR_WHITE Pixel

nCol+=65
@ nLin+4,nCol 		say "TOTAL" font oFont17n COLOR CLR_YELLOW Pixel

nLin+=IIf(lDipMob,8,15)
@ nLin,005 To nLin+IIf(lDipMob,024,39),IIf(lDipMob,130,100) COLOR CLR_WHITE Pixel

@ nLin,110 To nLin+IIf(lDipMob,040,39),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel

//Colunas
@ nLin,IIf(lDipMob,079,175) To nLin+IIf(lDipMob,40,39),IIf(lDipMob,080,176) COLOR CLR_WHITE Pixel
@ nLin,IIf(lDipMob,079,240) To nLin+IIf(lDipMob,40,39),IIf(lDipMob,080,241) COLOR CLR_WHITE Pixel
@ nLin,IIf(lDipMob,079,305) To nLin+IIf(lDipMob,40,39),IIf(lDipMob,080,306) COLOR CLR_WHITE Pixel

//Linhas
@ nLin+IIf(lDipMob,07,13),005 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,100,100) COLOR CLR_WHITE Pixel
@ nLin+IIf(lDipMob,15,26),005 To nLin+IIf(lDipMob,16,27),IIf(lDipMob,100,100) COLOR CLR_WHITE Pixel

@ nLin+IIf(lDipMob,07,13),110 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel
@ nLin+IIf(lDipMob,15,26),110 To nLin+IIf(lDipMob,16,27),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel

nLin+=IIf(lDipMob,2,2)

@ nLin,008 say "Meta "+SubStr(DtoS(Date()),5,2)+"/"+Left(DtoS(Date()),4) font oFont17 COLOR CLR_WHITE Pixel

@ nLin ,IIf(lDipMob,055,115) say PadL(TransForm(_nVlrMPar,"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel
@ nLin ,IIf(lDipMob,055,180) say PadL(TransForm(_nVlrMPub,"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel
@ nLin ,IIf(lDipMob,055,245) say PadL(TransForm(_nVlrMTel,"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel
@ nLin ,IIf(lDipMob,055,310) say PadL(TransForm(_nVlrMeta,"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel

nLin+=IIf(lDipMob,8,13)
@ nLin,008 say "Falta p/ Meta"					 font oFont17 COLOR CLR_WHITE Pixel
@ nLin,IIf(lDipMob,105,065) say TransForm(((_nVlrMeta-(aResFat[5]+aResPV[5]))*100)/_nVlrMeta,"@E 999.99")+"%" font oFont17 COLOR CLR_WHITE Pixel

@ nLin ,IIf(lDipMob,055,115) say PadL(TransForm(_nVlrMPar-(aResFat[1]+aResPV[1]),"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel
@ nLin ,IIf(lDipMob,055,180) say PadL(TransForm(_nVlrMPub-(aResFat[2]+aResPV[2]),"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel
@ nLin ,IIf(lDipMob,055,245) say PadL(TransForm(_nVlrMTel-(aResFat[4]+aResPV[4]),"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel
@ nLin ,IIf(lDipMob,055,310) say PadL(TransForm(_nVlrMeta-(aResFat[5]+aResPV[5]),"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel

nLin+=IIf(lDipMob,8,13)
@ nLin,008 say "Tot. Atingido" 				 font oFont17n COLOR CLR_YELLOW Pixel
@ nLin,IIf(lDipMob,105,067) say TransForm((((aResFat[5]+aResPV[5])*100)/_nVlrMeta),"@E 999.99")+"%" font oFont17n COLOR CLR_YELLOW Pixel

@ nLin ,IIf(lDipMob,055,115) say PadL(TransForm(aResFat[1]+aResPV[1],"@E 999,999,999.99"),15) font oFont17n COLOR CLR_YELLOW Pixel
@ nLin ,IIf(lDipMob,055,180) say PadL(TransForm(aResFat[2]+aResPV[2],"@E 999,999,999.99"),15) font oFont17n COLOR CLR_YELLOW Pixel
@ nLin ,IIf(lDipMob,055,245) say PadL(TransForm(aResFat[4]+aResPV[4],"@E 999,999,999.99"),15) font oFont17n COLOR CLR_YELLOW Pixel
@ nLin ,IIf(lDipMob,055,310) say PadL(TransForm(aResFat[5]+aResPV[5],"@E 999,999,999.99"),15) font oFont17n COLOR CLR_YELLOW Pixel

//______________________________________________________________________________
//                                           		 	                        |
//				F A T U R A M E N T O - HQ										|
//______________________________________________________________________________|
//
/*
aResFatHQ := fQuery01("040")
aResPVHQ  := fQuery03("040")

nLin+=IIf(lDipMob,15,29)
@ nLin+2,005 say "PREV. FATURAM. - HQ"	font oFont17n COLOR CLR_HRED Pixel

@ nLin+2,308	 	say "TOTAL" 			font oFont17n COLOR CLR_YELLOW Pixel

nLin+=IIf(lDipMob,8,13)
@ nLin,005 To nLin+IIf(lDipMob,40,65),IIf(lDipMob,130,100) COLOR CLR_WHITE Pixel

@ nLin,305 To nLin+IIf(lDipMob,40,65),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel

@ nLin	 ,110 say Replicate(".",75) font oFont17n COLOR CLR_WHITE Pixel
@ nLin+13,110 say Replicate(".",75) font oFont17n COLOR CLR_WHITE Pixel
@ nLin+26,110 say Replicate(".",75) font oFont17n COLOR CLR_WHITE Pixel
@ nLin+39,110 say Replicate(".",75) font oFont17n COLOR CLR_WHITE Pixel
@ nLin+52,110 say Replicate(".",75) font oFont17n COLOR CLR_WHITE Pixel

//Linhas
@ nLin+IIf(lDipMob,07,13),005 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,100) COLOR CLR_WHITE Pixel
@ nLin+IIf(lDipMob,15,26),005 To nLin+IIf(lDipMob,16,27),IIf(lDipMob,130,100) COLOR CLR_WHITE Pixel
@ nLin+IIf(lDipMob,23,39),005 To nLin+IIf(lDipMob,24,40),IIf(lDipMob,130,100) COLOR CLR_WHITE Pixel
@ nLin+IIf(lDipMob,31,52),005 To nLin+IIf(lDipMob,32,53),IIf(lDipMob,130,100) COLOR CLR_WHITE Pixel

@ nLin+IIf(lDipMob,07,13),305 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel
@ nLin+IIf(lDipMob,15,26),305 To nLin+IIf(lDipMob,16,27),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel
@ nLin+IIf(lDipMob,23,39),305 To nLin+IIf(lDipMob,24,40),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel
@ nLin+IIf(lDipMob,31,52),305 To nLin+IIf(lDipMob,32,53),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel

nLin+=IIf(lDipMob,2,2)
@ nLin,008 say "Faturado Dia ("+Left(DtoC(DataValida(Date()-1,.F.)),5)+")"  			 font oFont17 COLOR CLR_WHITE Pixel

@ nLin,IIf(lDipMob,85,310) say PadL(TransForm(aResFatHQ[3],"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel

nLin+=IIf(lDipMob,8,13)
@ nLin,008 say "Faturado Hoje (1)"			 font oFont17 COLOR CLR_WHITE Pixel  //("+Left(DtoC(Date()),5)+"

@ nLin,IIf(lDipMob,85,310) say PadL(TransForm(aResFatHQ[2],"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel

nLin+=IIf(lDipMob,8,13)
@ nLin,008 say "P.V. Liberados (2)" 					 font oFont17 COLOR CLR_WHITE Pixel

@ nLin,IIf(lDipMob,85,310) say PadL(TransForm(aResPVHQ[1],"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel

nLin+=IIf(lDipMob,8,13)
@ nLin,008 say "Previsto (1+2)"					 		font oFont17n COLOR CLR_WHITE Pixel

@ nLin ,IIf(lDipMob,85,310) say PadL(TransForm(aResFatHQ[2]+aResPVHQ[1],"@E 999,999,999.99"),15) font oFont17n COLOR CLR_WHITE Pixel

nLin+=IIf(lDipMob,8,13)
@ nLin,008 say "Total Fat.+Previsto" 					 font oFont17n COLOR CLR_YELLOW Pixel

@ nLin ,IIf(lDipMob,85,310) say PadL(TransForm(aResFatHQ[1]+aResPVHQ[1],"@E 999,999,999.99"),15) font oFont17n COLOR CLR_YELLOW Pixel
*/

//______________________________________________________________________________
//                                           		 	                        |
//						M E T A - HQ											|
//______________________________________________________________________________|
//
  
/*
nLin+=IIf(lDipMob,15,15)
@ nLin+2,005  say "INDIC. DE META - HQ"	font oFont17n COLOR CLR_HRED Pixel

@ nLin+2,308 say "TOTAL" 						font oFont17n COLOR CLR_YELLOW Pixel

nLin+=IIf(lDipMob,8,13)
@ nLin,005 To nLin+IIf(lDipMob,024,39),IIf(lDipMob,130,100) COLOR CLR_WHITE Pixel

@ nLin,305 To nLin+IIf(lDipMob,40,39),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel

//Linhas
@ nLin+IIf(lDipMob,07,13),005 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,100) COLOR CLR_WHITE Pixel
@ nLin+IIf(lDipMob,15,26),005 To nLin+IIf(lDipMob,16,27),IIf(lDipMob,130,100) COLOR CLR_WHITE Pixel

@ nLin+IIf(lDipMob,07,13),305 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel
@ nLin+IIf(lDipMob,15,26),305 To nLin+IIf(lDipMob,16,27),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel

@ nLin	 ,110 say Replicate(".",75) font oFont17n COLOR CLR_WHITE Pixel
@ nLin+13,110 say Replicate(".",75) font oFont17n COLOR CLR_WHITE Pixel
@ nLin+26,110 say Replicate(".",75) font oFont17n COLOR CLR_WHITE Pixel

nLin+=IIf(lDipMob,2,2)

@ nLin,008 say "Meta HQ "+SubStr(DtoS(Date()),5,2)+"/"+Left(DtoS(Date()),4) font oFont17 COLOR CLR_WHITE Pixel
@ nLin ,IIf(lDipMob,055,310) say PadL(TransForm(_nVlrMHQ,"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel

nLin+=IIf(lDipMob,8,13)
@ nLin,008 say "Falta p/ Meta"					 font oFont17 COLOR CLR_WHITE Pixel
@ nLin,IIf(lDipMob,105,065) say TransForm(((_nVlrMHQ-(aResFatHQ[1]+aResPVHQ[1]))*100)/_nVlrMHQ,"@E 999.99")+"%" font oFont17 COLOR CLR_WHITE Pixel
@ nLin ,IIf(lDipMob,055,310) say PadL(TransForm(_nVlrMHQ-(aResFatHQ[1]+aResPVHQ[1]),"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel


nLin+=IIf(lDipMob,8,13)
@ nLin,008 say "Tot. Atingido" 				 font oFont17n COLOR CLR_YELLOW Pixel
@ nLin,IIf(lDipMob,105,067) say TransForm((((aResFatHQ[1]+aResPVHQ[1])*100)/_nVlrMHQ),"@E 999.99")+"%" font oFont17n COLOR CLR_YELLOW Pixel
@ nLin ,IIf(lDipMob,055,310) say PadL(TransForm(aResFatHQ[1]+aResPVHQ[1],"@E 999,999,999.99"),15) font oFont17n COLOR CLR_YELLOW Pixel 

*/


//______________________________________________________________________________
//                                           		 	                         |
//				P R I N C I P A I S   C L I E N T E S      					  	 |
//_____________________________________________________________________________|
//
If Empty(aTopFat) 
	aTopFat := fQuery04("010")
	 
	cTime1 := time()
	cTime :=cTime1
Else
	cTime2 := Time()
	
	For nV := 1 To nVezes
		If ABS(int(SubHoras( cTime1, cTime2 )/3)) == nV .and. nProc == (nV-1)
			aTopFat := {}
			aTopFat := fQuery04("010")	
			nProc ++
			cTime := time()

		Endif
	Next nV
Endif 

	nLin+=IIf(lDipMob,7,12)
	@ nLin+2,005 say "PRINCIPAIS CLIENTES - " + cTime	font oFont17n COLOR CLR_HRED Pixel
	@ nLin+2,308	 	say "TOTAL" 			font oFont17n COLOR CLR_YELLOW Pixel

	If Empty(aTopFat)

		nLin+=IIf(lDipMob,6,12)
		@ nLin,005 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,100)+20 COLOR CLR_WHITE Pixel

		@ nLin,305 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel

		@ nLin,110+25 say Replicate(".",65) font oFont17n COLOR CLR_WHITE Pixel
		nLin+=IIf(lDipMob,2,2)

		@ nLin,008 say "SEM DADOS "  			 font oFont17 COLOR CLR_WHITE Pixel

		@ nLin,IIf(lDipMob,85,310) say PadL(TransForm(0,"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel


	Endif

If !Empty(aTopFat)
		nLin+=IIf(lDipMob,6,12)
		@ nLin,005 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,100)+20 COLOR CLR_WHITE Pixel

		@ nLin,305 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel

		@ nLin,110+25 say Replicate(".",65) font oFont17n COLOR CLR_WHITE Pixel
		nLin+=IIf(lDipMob,2,2)

		@ nLin,008 say If(len(aTopFat)>=1, aTopFat[01][01],"")  			 font oFont17 COLOR CLR_WHITE Pixel

		@ nLin,IIf(lDipMob,85,310) say PadL(TransForm(If(len(aTopFat)>=1,aTopFat[01][02],0),"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel


		nLin+=IIf(lDipMob,6,12)
		@ nLin,005 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,100)+20 COLOR CLR_WHITE Pixel

		@ nLin,305 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel

		@ nLin,110+25 say Replicate(".",65) font oFont17n COLOR CLR_WHITE Pixel
		nLin+=IIf(lDipMob,2,2)

		@ nLin,008 say If(len(aTopFat)>=2, aTopFat[02][01],"")   			 font oFont17 COLOR CLR_WHITE Pixel

		@ nLin,IIf(lDipMob,85,310) say PadL(TransForm(If(len(aTopFat)>=2,aTopFat[02][02],0),"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel

		nLin+=IIf(lDipMob,6,12)
		@ nLin,005 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,100)+20 COLOR CLR_WHITE Pixel

		@ nLin,305 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel

		@ nLin,110+25 say Replicate(".",65) font oFont17n COLOR CLR_WHITE Pixel
		nLin+=IIf(lDipMob,2,2)

		@ nLin,008 say If(len(aTopFat)>=3, aTopFat[03][01],"")   			 font oFont17 COLOR CLR_WHITE Pixel

		@ nLin,IIf(lDipMob,85,310) say PadL(TransForm(If(len(aTopFat)>=3,aTopFat[03][02],0),"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel

		nLin+=IIf(lDipMob,6,12)
		@ nLin,005 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,100)+20 COLOR CLR_WHITE Pixel

		@ nLin,305 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel

		@ nLin,110+25 say Replicate(".",65) font oFont17n COLOR CLR_WHITE Pixel
		nLin+=IIf(lDipMob,2,2)

		@ nLin,008 say If(len(aTopFat)>=4, aTopFat[04][01],"")  			 font oFont17 COLOR CLR_WHITE Pixel

		@ nLin,IIf(lDipMob,85,310) say PadL(TransForm(If(len(aTopFat)>=4,aTopFat[04][02],0),"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel


		nLin+=IIf(lDipMob,6,12)
		@ nLin,005 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,100)+20 COLOR CLR_WHITE Pixel

		@ nLin,305 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel

		@ nLin,110+25 say Replicate(".",65) font oFont17n COLOR CLR_WHITE Pixel
		nLin+=IIf(lDipMob,2,2)

		@ nLin,008 say If(len(aTopFat)>=5, aTopFat[05][01],"")  			 font oFont17 COLOR CLR_WHITE Pixel

		@ nLin,IIf(lDipMob,85,310) say PadL(TransForm(If(len(aTopFat)>=5,aTopFat[05][02],0),"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel


		nLin+=IIf(lDipMob,6,12)
		@ nLin,005 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,100)+20 COLOR CLR_WHITE Pixel

		@ nLin,305 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel

		@ nLin,110+25 say Replicate(".",65) font oFont17n COLOR CLR_WHITE Pixel
		nLin+=IIf(lDipMob,2,2)

		@ nLin,008 say If(len(aTopFat)>=6, aTopFat[06][01],"")  			 font oFont17 COLOR CLR_WHITE Pixel

		@ nLin,IIf(lDipMob,85,310) say PadL(TransForm(If(len(aTopFat)>=6,aTopFat[06][02],0),"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel


		nLin+=IIf(lDipMob,6,12)
		@ nLin,005 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,100)+20 COLOR CLR_WHITE Pixel

		@ nLin,305 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel

		@ nLin,110+25 say Replicate(".",65) font oFont17n COLOR CLR_WHITE Pixel
		nLin+=IIf(lDipMob,2,2)

		@ nLin,008 say If(len(aTopFat)>=7, aTopFat[07][01],"") 			 font oFont17 COLOR CLR_WHITE Pixel

		@ nLin,IIf(lDipMob,85,310) say PadL(TransForm(If(len(aTopFat)>=7,aTopFat[07][02],0),"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel


		nLin+=IIf(lDipMob,6,12)
		@ nLin,005 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,100)+20 COLOR CLR_WHITE Pixel

		@ nLin,305 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel

		@ nLin,110+25 say Replicate(".",65) font oFont17n COLOR CLR_WHITE Pixel
		nLin+=IIf(lDipMob,2,2)

		@ nLin,008 say If(len(aTopFat)>=8, aTopFat[08][01],"") 			 font oFont17 COLOR CLR_WHITE Pixel

		@ nLin,IIf(lDipMob,85,310) say PadL(TransForm(If(len(aTopFat)>=8,aTopFat[08][02],0),"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel


		nLin+=IIf(lDipMob,6,12)
		@ nLin,005 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,100)+20 COLOR CLR_WHITE Pixel

		@ nLin,305 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel

		@ nLin,110+25 say Replicate(".",65) font oFont17n COLOR CLR_WHITE Pixel
		nLin+=IIf(lDipMob,2,2)

		@ nLin,008 say If(len(aTopFat)>=9, aTopFat[09][01],"")  			 font oFont17 COLOR CLR_WHITE Pixel

		@ nLin,IIf(lDipMob,85,310) say PadL(TransForm(If(len(aTopFat)>=9,aTopFat[09][02],0),"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel


		nLin+=IIf(lDipMob,6,12)
		@ nLin,005 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,100)+20 COLOR CLR_WHITE Pixel

		@ nLin,305 To nLin+IIf(lDipMob,08,14),IIf(lDipMob,130,375) COLOR CLR_WHITE Pixel

		@ nLin,110+25 say Replicate(".",65) font oFont17n COLOR CLR_WHITE Pixel
		nLin+=IIf(lDipMob,2,2)

		@ nLin,008 say If(len(aTopFat)>=10, aTopFat[10][01],"")  			 font oFont17 COLOR CLR_WHITE Pixel

		@ nLin,IIf(lDipMob,85,310) say PadL(TransForm(If(len(aTopFat)>=10,aTopFat[10][02],0),"@E 999,999,999.99"),15) font oFont17 COLOR CLR_WHITE Pixel
ENDIF

//______________________________________________________________________________
//                                           		 	                        |
//				F O R N E C E D O R  - X -  M A R G E M 						|
//______________________________________________________________________________|
//

aSort(aFornec,,,{|X,Y| X[3] > Y[3]})

nLin2 := 5
nLin2+=IIf(lDipMob,8,25)
@ nLin2+4,388 say "MARGEM POR FORNECEDOR"	font oFont17n COLOR CLR_HRED Pixel

nLin2+=IIf(lDipMob,8,15)
@ nLin2,385 To nLin2+IIf(lDipMob,40,273),IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel

//Colunas
@ nLin2,IIf(lDipMob,079,475) To nLin2+IIf(lDipMob,40,273),IIf(lDipMob,080,476) COLOR CLR_WHITE Pixel
@ nLin2,IIf(lDipMob,079,530) To nLin2+IIf(lDipMob,40,273),IIf(lDipMob,080,531) COLOR CLR_WHITE Pixel
@ nLin2,IIf(lDipMob,079,585) To nLin2+IIf(lDipMob,40,273),IIf(lDipMob,080,586) COLOR CLR_WHITE Pixel


//Linhas                                 

@ nLin2+2,388 say "FORNECEDOR" 	font oFont17n COLOR CLR_WHITE Pixel
@ nLin2+2,478 say "FATURAM."	font oFont17n COLOR CLR_WHITE Pixel
@ nLin2+2,533 say "CUSTO" 		font oFont17n COLOR CLR_WHITE Pixel
@ nLin2+2,588 say "MARGEM" 		font oFont17n COLOR CLR_YELLOW Pixel

nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel
                 
If Len(aFornec)>1
	@ nLin2+2,388 say PADR(aFornec[1,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[1,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[1,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[1,3]/aFornec[1,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf

nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel

If Len(aFornec)>2
	@ nLin2+2,388 say PADR(aFornec[2,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[2,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[2,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[2,3]/aFornec[2,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf

nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel

If Len(aFornec)>3
	@ nLin2+2,388 say PADR(aFornec[3,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[3,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[3,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[3,3]/aFornec[3,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf

nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel

If Len(aFornec)>4
	@ nLin2+2,388 say PADR(aFornec[4,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[4,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[4,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[4,3]/aFornec[4,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf

nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel

If Len(aFornec)>5
	@ nLin2+2,388 say PADR(aFornec[5,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[5,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[5,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[5,3]/aFornec[5,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf
	
nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel

If Len(aFornec)>6
	@ nLin2+2,388 say PADR(aFornec[6,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[6,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[6,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[6,3]/aFornec[6,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf
	
nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel

If Len(aFornec)>7
	@ nLin2+2,388 say PADR(aFornec[7,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[7,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[7,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[7,3]/aFornec[7,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf

nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel
                 
If Len(aFornec)>8
	@ nLin2+2,388 say PADR(aFornec[8,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[8,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[8,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[8,3]/aFornec[8,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf

nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel

If Len(aFornec)>9
	@ nLin2+2,388 say PADR(aFornec[9,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[9,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[9,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[9,3]/aFornec[9,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf

nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel

If Len(aFornec)>10
	@ nLin2+2,388 say PADR(aFornec[10,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[10,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[10,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[10,3]/aFornec[10,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf

nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel

If Len(aFornec)>11
	@ nLin2+2,388 say PADR(aFornec[11,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[11,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[11,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[11,3]/aFornec[11,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf

nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel
                                       
If Len(aFornec)>12
	@ nLin2+2,388 say PADR(aFornec[12,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[12,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[12,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[12,3]/aFornec[12,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf
	
nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel

If Len(aFornec)>13
	@ nLin2+2,388 say PADR(aFornec[13,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[13,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[13,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[13,3]/aFornec[13,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf

nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel

If Len(aFornec)>14
	@ nLin2+2,388 say PADR(aFornec[14,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[14,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[14,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[14,3]/aFornec[14,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf
	
nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel

If Len(aFornec)>15
	@ nLin2+2,388 say PADR(aFornec[15,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[15,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[15,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[15,3]/aFornec[15,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf

nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel

If Len(aFornec)>16
	@ nLin2+2,388 say PADR(aFornec[16,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[16,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[16,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[16,3]/aFornec[16,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf
	
nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel

If Len(aFornec)>17
	@ nLin2+2,388 say PADR(aFornec[17,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[17,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[17,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[17,3]/aFornec[17,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf
	
nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel

If Len(aFornec)>18
	@ nLin2+2,388 say PADR(aFornec[18,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[18,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[18,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[18,3]/aFornec[18,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf
	
nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel

If Len(aFornec)>19
	@ nLin2+2,388 say PADR(aFornec[19,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[19,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[19,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[19,3]/aFornec[19,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf
	
nLin2+=13
@ nLin2,IIf(lDipMob,07,385) To nLin2+1,IIf(lDipMob,130,630) COLOR CLR_WHITE Pixel

If Len(aFornec)>20
	@ nLin2+2,388 say PADR(aFornec[20,2],18) font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,478 say TransForm(aFornec[20,3],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,533 say TransForm(aFornec[20,4],"@E 99,999,999.99") font oFont17 COLOR CLR_WHITE Pixel
	@ nLin2+2,588 say TransForm(Round((aFornec[20,3]/aFornec[20,4]-1)*100,2),"@E 999.99 %") font oFont17n COLOR CLR_YELLOW Pixel
EndIf	

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (SLEEP(300000),oDlg:End())

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery01  บAutor  ณJailton B Santos-JBSบ Data ณ 03/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esta Query apura os falores faturado no pedido pela empresaบฑฑ
ฑฑบ          ณ informada como parametro, Retorna Query QRY1.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - Faturamento - DIPROMED.                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fQuery01(_cEmpQry)
Local cSQL    	 := ""
Local cAnoMes 	 := Left(Dtos(Date()),6)
Local aRet	  	 := {}  
DEFAULT _cEmpQry := ""

Private cFornVend  := AllTrim(GetNewPar("MV_FORNVEN",""))

cSQL := " SELECT "
cSQL += " 		ROUND(SUM(CASE F4_DUPLIC WHEN 'S' THEN (D2_TOTAL+D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET ) ELSE (D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET ) END),2) AS F2_VALFAT, "
cSQL += " 		U7_POSTO, "
cSQL += " 		F2_VEND1, "
cSQL += " 		F2_VEND2, "
cSQL += " 		D2_FORNEC, "
cSQL += " 		C5_OPERADO, "
cSQL += " 		F2_EMISSAO, "
cSQL += " 		U7_CODVEN, "                         
cSQL += "		SUM(CASE F4_DUPLIC WHEN 'S' THEN D2_TOTAL ELSE 0 END ) FAT_MARG, "
cSQL += "		CASE WHEN D2_FORNEC IN('"+StrTran(GetNewPar("ES_LISFOR","000041/000609/000334/000338/000183/100000/000630/000996/000997"),"/","','")+"') THEN "
cSQL += "		SUM(D2_QUANT * D2_LISFOR) ELSE "
cSQL += "		SUM(D2_QUANT * D2_CUSDIP) END CUSTO "
cSQL += "   	FROM "
cSQL += "  			SF2"+_cEmpQry+" SF2 WITH(NOLOCK), SC5"+_cEmpQry+" SC5 WITH(NOLOCK), SU7010 SU7 WITH(NOLOCK), SD2"+_cEmpQry+" SD2 WITH(NOLOCK), SF4"+_cEmpQry+" SF4 WITH(NOLOCK) "
cSQL += "  			WHERE "
cSQL += " 				F2_FILIAL IN('01','04') AND "
cSQL += " 				LEFT(F2_EMISSAO,6) = '"+cAnoMes+"' AND "
cSQL += " 				F2_TIPO IN ('N','C') AND "
cSQL += " 				F2_FILIAL  = D2_FILIAL AND "
cSQL += " 				F2_DOC     = D2_DOC AND "
cSQL += " 				F2_SERIE   = D2_SERIE AND " 
cSQL += " 				F2_CLIENTE = D2_CLIENTE AND "
cSQL += " 				F2_LOJA    = D2_LOJA AND "
cSQL += " 				F2_VEND1   <> '006874' AND "
cSQL += " 				D2_FILIAL  = F4_FILIAL AND "
cSQL += " 				D2_TES 	   = F4_CODIGO AND "
cSQL += " 				(F4_DUPLIC = 'S' or D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET  > 0 ) AND "
cSQL += " 				F4_FILIAL  = D2_FILIAL AND "
cSQL += " 				D2_FILIAL  = C5_FILIAL AND "
cSQL += " 				D2_PEDIDO  = C5_NUM AND "
cSQL += " 				D2_CLIENTE = C5_CLIENTE AND "
cSQL += " 				D2_LOJA    = C5_LOJACLI AND "
cSQL += " 				U7_FILIAL  = ' ' AND "
cSQL += " 				C5_OPERADO = U7_COD AND "
cSQL += " 				SF2.D_E_L_E_T_ = ' ' AND "
cSQL += " 				SC5.D_E_L_E_T_ = ' ' AND "
cSQL += " 				SU7.D_E_L_E_T_ = ' ' AND "
cSQL += " 				SD2.D_E_L_E_T_ = ' ' AND "
cSQL += " 				SF4.D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY U7_POSTO ,F2_VEND1, F2_VEND2, D2_FORNEC, C5_OPERADO, U7_CODVEN, F2_EMISSAO "

//cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYGRA1",.T.,.T.)

TCSETFIELD("QRYGRA1","F2_VALFAT","N",17,2)

While !QRYGRA1->(Eof())                                                
	If _cEmpQry == "010"
		If ((Empty(QRYGRA1->F2_VEND2) .OR. ;
			(!Empty(QRYGRA1->F2_VEND2) .AND. !(QRYGRA1->D2_FORNEC $ cFornVend))).AND. ;
			!Empty(QRYGRA1->U7_CODVEN) .and. ;
			QRYGRA1->F2_VEND1 <> '000204') .or. ;
			QRYGRA1->F2_VEND1 $ '006684/000353/000352/000356/000357/000359'
			
			DipSomFat("TEL",QRYGRA1->F2_EMISSAO,QRYGRA1->F2_VALFAT,.T.)		
		Else
			If QRYGRA1->U7_POSTO == "03"
				DipSomFat("PUB",QRYGRA1->F2_EMISSAO,QRYGRA1->F2_VALFAT,.T.)
			Else
				DipSomFat("PAR",QRYGRA1->F2_EMISSAO,QRYGRA1->F2_VALFAT,.T.)
			EndIf    
		EndIf
		
		If (nPos:=aScan(aFornec,{|x| x[1]==QRYGRA1->D2_FORNEC}))==0
			aAdd(aFornec,{	QRYGRA1->D2_FORNEC,;
							POSICIONE("SA2",1,xFilial("SA2")+QRYGRA1->D2_FORNEC,"A2_NREDUZ"),;
							QRYGRA1->FAT_MARG,;
							QRYGRA1->CUSTO})
		Else
			aFornec[nPos,3] += QRYGRA1->FAT_MARG
			aFornec[nPos,4] += QRYGRA1->CUSTO
		EndIf
	Else     
		_nTotHQ += QRYGRA1->F2_VALFAT
		
		If QRYGRA1->F2_EMISSAO == DtoS(Date())                                                 
			_nTotHHQ +=	QRYGRA1->F2_VALFAT
		ElseIf Day(Date())>1 .And. QRYGRA1->F2_EMISSAO == DtoS(DataValida(Date()-1,.F.))
		   	_nTotAHQ += QRYGRA1->F2_VALFAT
		EndIf
	EndIf
	QRYGRA1->(dbSkip())
EndDo
QRYGRA1->(dbCloseArea())  

fQuery02(_cEmpQry)          
          
If _cEmpQry=="010"
	aAdd(aRet,_nPar)
	aAdd(aRet,_nPub)
	aAdd(aRet,_nRep)
	aAdd(aRet,_nTel)
	aAdd(aRet,_nTot)
	aAdd(aRet,_nTotH)
	aAdd(aRet,_nTotA)
	aAdd(aRet,_nParH)
	aAdd(aRet,_nPubH)
	aAdd(aRet,_nRepH)
	aAdd(aRet,_nTelH)
	aAdd(aRet,_nParA)
	aAdd(aRet,_nPubA)
	aAdd(aRet,_nRepA)
	aAdd(aRet,_nTelA)
Else                 
	aAdd(aRet,_nTotHQ)
	aAdd(aRet,_nTotHHQ)
	aAdd(aRet,_nTotAHQ)
EndIf
Return(aRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery02  บAutor  ณJailton B Santos-JBSบ Data ณ 03/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esta Query apura os valores das devolucoes na empresa      บฑฑ
ฑฑบ          ณ informada como parametro, Retorna Query QRY2               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - Faturamento - DIPROMED.                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fQuery02(_cEmpQry)
Local cSQL    	 := "" 
Local cAnoMes 	 := Left(Dtos(Date()),6)
DEFAULT _cEmpQry := ""

cSQL := " SELECT "
cSQL += " 		SUM( CASE F4_DUPLIC WHEN 'S' THEN (D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET) ELSE (D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET) END) D1_TOTAL, "
cSQL += "		U7_POSTO, "
cSQL += "		C5_VEND2, "
cSQL += "		D2_FORNEC, "
cSQL += "		U7_CODVEN, "
cSQL += "		F2_VEND1, "
cSQL += "		D1_DTDIGIT, "                                                     
cSQL += "		SUM(CASE F4_DUPLIC WHEN 'S' THEN D1_TOTAL ELSE 0 END ) FAT_MARG, "
cSQL += "		CASE WHEN D2_FORNEC IN('"+StrTran(GetNewPar("ES_LISFOR","000041/000609/000334/000338/000183/100000/000630/000996/000997"),"/","','")+"') THEN "
cSQL += "		SUM(D1_QUANT * D2_LISFOR) ELSE "
cSQL += "		SUM(D1_QUANT * D2_CUSDIP) END CUSTO "
cSQL += " 		FROM "
cSQL += " 			SD1"+_cEmpQry+"  SD1 WITH(NOLOCK), SC5"+_cEmpQry+" SC5 WITH(NOLOCK), SU7010  SU7 WITH(NOLOCK), SD2"+_cEmpQry+"  SD2 WITH(NOLOCK), SF4"+_cEmpQry+" SF4 WITH(NOLOCK), SF2"+_cEmpQry+"  SF2 WITH(NOLOCK) "
cSQL += " 			WHERE " 
cSQL += " 				D1_FILIAL IN('01','04') AND "
cSQL += " 				D1_TIPO = 'D' AND "
cSQL += " 				LEFT(D1_DTDIGIT,6) = '"+cAnoMes+"' AND "
cSQL += " 				D1_FILIAL  = D2_FILIAL AND "
cSQL += " 				D1_NFORI   = D2_DOC AND "
cSQL += " 				D1_SERIORI = D2_SERIE AND "
cSQL += " 				D1_ITEMORI = D2_ITEM AND "
cSQL += " 				D1_FILIAL  = F4_FILIAL AND "
cSQL += " 				D1_TES     = F4_CODIGO AND "
cSQL += " 				(F4_DUPLIC = 'S' or D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET > 0 ) AND "    // JBS 03/08/2010 - Incluido o Or para conciderar a brindes e amostras.
cSQL += " 				F2_FILIAL  = SD2.D2_FILIAL AND "
cSQL += " 				F2_DOC     = D2_DOC    AND "
cSQL += " 				F2_SERIE   = D2_SERIE  AND "
cSQL += " 				F2_CLIENTE = D2_CLIENTE  AND "
cSQL += " 				F2_LOJA	   = D2_LOJA  AND "    
cSQL += " 				F2_VEND1   <> '006874' AND "
cSQL += " 				D2_FILIAL  = C5_FILIAL AND "
cSQL += " 				D2_PEDIDO  = C5_NUM AND "  
cSQL += " 				U7_FILIAL  = ' ' AND "
cSQL += " 				C5_OPERADO = U7_COD AND "
cSQL += " 				SD1.D_E_L_E_T_ = ' ' AND "
cSQL += " 				SC5.D_E_L_E_T_ = ' ' AND "
cSQL += " 				SU7.D_E_L_E_T_ = ' ' AND "
cSQL += " 				SD2.D_E_L_E_T_ = ' ' AND "
cSQL += " 				SF2.D_E_L_E_T_ = ' ' AND "
cSQL += " 				SF4.D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY U7_POSTO, C5_VEND2, D2_FORNEC, U7_CODVEN, F2_VEND1, D1_DTDIGIT, D1_QUANT "

//cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYGRA2",.T.,.T.)

TCSETFIELD("QRYGRA2","D1_TOTAL","N",17,2)

While !QRYGRA2->(Eof())                
	If _cEmpQry=="010"
		If ((Empty(QRYGRA2->C5_VEND2) .OR. ;
			(!Empty(QRYGRA2->C5_VEND2) .AND. !(QRYGRA2->D2_FORNEC $ cFornVend))).AND. ;
			!Empty(QRYGRA2->U7_CODVEN) .and. ;
			QRYGRA2->F2_VEND1 <> '000204') .or. ;
			QRYGRA2->F2_VEND1 $ '006684/000353/000352/000356/000357/000359'	
			
			DipSomFat("TEL",QRYGRA2->D1_DTDIGIT,QRYGRA2->D1_TOTAL)			
			
		Else
			If QRYGRA2->U7_POSTO=="03"
				DipSomFat("PUB",QRYGRA2->D1_DTDIGIT,QRYGRA2->D1_TOTAL)
			Else
				DipSomFat("PAR",QRYGRA2->D1_DTDIGIT,QRYGRA2->D1_TOTAL)
			EndIf		
		EndIf                                
		
		If (nPos:=aScan(aFornec,{|x| x[1]==QRYGRA2->D2_FORNEC}))==0
			aAdd(aFornec,{	QRYGRA2->D2_FORNEC,;
							POSICIONE("SA2",1,xFilial("SA2")+QRYGRA2->D2_FORNEC,"A2_NREDUZ"),;
							-QRYGRA2->FAT_MARG,;
							-QRYGRA2->CUSTO})
		Else
			aFornec[nPos,3] -= QRYGRA2->FAT_MARG
			aFornec[nPos,4] -= QRYGRA2->CUSTO
		EndIf
	Else 
		_nTotHQ -= QRYGRA2->D1_TOTAL
		
		If QRYGRA2->D1_DTDIGIT == DtoS(Date())                                                 
			_nTotHHQ -=	QRYGRA2->D1_TOTAL
		ElseIf Day(Date())>1 .And. QRYGRA2->D1_DTDIGIT == DtoS(DataValida(Date()-1,.F.))
		   	_nTotAHQ -= QRYGRA2->D1_TOTAL
		EndIf
	EndIf
	QRYGRA2->(dbSkip())	
EndDo
QRYGRA2->(dbCloseArea())

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery03  บAutor  ณJailton B Santos-JBSบ Data ณ 03/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esta Query apura os valores dos pedidos da empresa infor-  บฑฑ
ฑฑบ          ณ mada como parametro. Retorna QRY3.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - Faturamento - DIPROMED.                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fQuery03(_cEmpQry)
Local cSQL     	 := ""
Local cAnoMes  	 := Left(Dtos(Date()),6)
Local aRet	   	 := {}
Local _nPVLTel 	 := 0  
DEFAULT _cEmpQry := ""

cSQL := " SELECT " 
cSQL += " 	ROUND(SUM(C9_VALOR),2) C9_VALOR, "
cSQL += " 	U7_POSTO, " 		
cSQL += " 	C5_VEND2, " 		
cSQL += " 	B1_PROC, "   		
cSQL += " 	U7_CODVEN, " 		
cSQL += " 	C5_VEND1, " 		
cSQL +=	" 	C5_EMISSAO "   
cSQL += " 	FROM ( "
cSQL += "       SELECT "
cSQL += "	 		C9_QTDLIB*C9_PRCVEN  C9_VALOR, "
cSQL += "			U7_POSTO, "
cSQL += "			C5_VEND2, "
cSQL += "			B1_PROC,  "
cSQL += "			U7_CODVEN, "
cSQL += "			C5_VEND1, "
cSQL += "			C5_EMISSAO "
cSQL += " 			FROM "
cSQL += " 	 			SC5"+_cEmpQry+" SC5 WITH(NOLOCK), "
cSQL += " 				SC6"+_cEmpQry+" SC6 WITH(NOLOCK), "
cSQL += " 				SC9"+_cEmpQry+" SC9 WITH(NOLOCK), "
cSQL += " 				SU7010 SU7 WITH(NOLOCK), "
cSQL += " 				SB1"+_cEmpQry+" SB1 WITH(NOLOCK), "
cSQL += " 				SF4"+_cEmpQry+" SF4 WITH(NOLOCK) "
cSQL += " 				WHERE " 			
cSQL += " 					C5_FILIAL   = '01' AND "
cSQL += " 					C5_TIPO 	= 'N' AND "
cSQL += " 					C5_PARCIAL 	= ' ' AND "
cSQL += " 					C5_VEND1 	<> '006874' AND "
cSQL += " 					C5_FILIAL 	= C6_FILIAL AND "
cSQL += " 					C5_NUM 		= C6_NUM AND "
cSQL += " 					C5_CLIENTE 	= C6_CLI AND "
cSQL += " 					C5_LOJACLI 	= C6_LOJA AND "
cSQL += " 					C6_FILIAL 	= F4_FILIAL AND "
cSQL += " 					C6_TES    	= F4_CODIGO AND "
cSQL += " 					F4_DUPLIC 	= 'S' AND "
cSQL += " 					C9_FILIAL 	= C6_FILIAL AND "
cSQL += "					C9_PEDIDO 	= C6_NUM AND "
cSQL += " 					C9_CLIENTE 	= C6_CLI AND "
cSQL += " 					C9_LOJA 	= C6_LOJA AND "
cSQL += " 					C9_ITEM   	= C6_ITEM AND "
cSQL += " 					C9_SALDO 	= 0 AND "
cSQL += " 					C9_BLCRED 	= ' ' AND "
cSQL += " 					C9_BLCRED2 	= ' ' AND "
cSQL += " 					C9_BLEST IN(' ','02') AND "
cSQL += "					U7_FILIAL  	= ' ' AND "
cSQL += "					C5_OPERADO 	= U7_COD AND "
cSQL += "					B1_FILIAL  	= C9_FILIAL AND "
cSQL += "					B1_COD 		= C9_PRODUTO AND "
cSQL += " 					SC9.D_E_L_E_T_ = ' ' AND "
cSQL += " 					SC6.D_E_L_E_T_ = ' ' AND "
cSQL += " 					SC5.D_E_L_E_T_ = ' ' AND "
cSQL += " 					SU7.D_E_L_E_T_ = ' ' AND "
cSQL += " 					SB1.D_E_L_E_T_ = ' ' AND "
cSQL += " 					SF4.D_E_L_E_T_ = ' ' "
cSQL += " 		UNION ALL"
cSQL += " 		SELECT "
cSQL += " 			C9_QTDLIB*C9_PRCVEN C9_VALOR, "
cSQL += "			U7_POSTO, "
cSQL += "			C5_VEND2, "
cSQL += "			B1_PROC,  "
cSQL += "			U7_CODVEN, "
cSQL += "			C5_VEND1, "
cSQL += "			C5_EMISSAO "
cSQL += " 			FROM "
cSQL += " 			 	SC5"+_cEmpQry+" SC5 WITH(NOLOCK), "
cSQL += " 				SC6"+_cEmpQry+" SC6 WITH(NOLOCK), "
cSQL += " 				SC9"+_cEmpQry+" SC9 WITH(NOLOCK), "
cSQL += " 				SU7010 SU7 WITH(NOLOCK), "
cSQL += " 				SB1"+_cEmpQry+" SB1 WITH(NOLOCK), "
cSQL += " 				SF4"+_cEmpQry+" SF4 WITH(NOLOCK) "
cSQL += " 				WHERE " 			
cSQL += " 					C5_FILIAL   = '04' AND "
cSQL += " 					C5_TIPO 	= 'N' AND "
cSQL += " 					C5_PARCIAL 	= ' ' AND "
cSQL += " 					C5_VEND1 	<> '006874' AND "
cSQL += " 					C5_FILIAL 	= C6_FILIAL AND "
cSQL += " 					C5_NUM 		= C6_NUM AND "
cSQL += " 					C5_CLIENTE 	= C6_CLI AND "
cSQL += " 					C5_LOJACLI 	= C6_LOJA AND "
cSQL += " 					C6_FILIAL 	= F4_FILIAL AND "
cSQL += " 					C6_TES    	= F4_CODIGO AND "
cSQL += " 					F4_DUPLIC 	= 'S' AND "
cSQL += " 					C9_FILIAL 	= C6_FILIAL AND "
cSQL += " 					C9_PEDIDO 	= C6_NUM AND "
cSQL += " 					C9_CLIENTE 	= C6_CLI AND "
cSQL += " 					C9_LOJA 	= C6_LOJA AND "
cSQL += " 					C9_ITEM   	= C6_ITEM AND "
cSQL += " 					C9_SALDO 	= 0 AND "
cSQL += " 					C9_BLCRED 	= ' ' AND "
cSQL += " 					C9_BLCRED2 	= ' ' AND "
cSQL += " 					C9_BLEST IN(' ','02') AND "
cSQL += "					U7_FILIAL  	= ' ' AND "
cSQL += "					C5_OPERADO 	= U7_COD AND "
cSQL += "					B1_FILIAL  	= C9_FILIAL AND "
cSQL += "					B1_COD 		= C9_PRODUTO AND "
cSQL += " 					SC9.D_E_L_E_T_ = ' ' AND "
cSQL += " 					SC6.D_E_L_E_T_ = ' ' AND "
cSQL += " 					SC5.D_E_L_E_T_ = ' ' AND "
cSQL += " 					SU7.D_E_L_E_T_ = ' ' AND "
cSQL += " 					SB1.D_E_L_E_T_ = ' ' AND "
cSQL += " 					SF4.D_E_L_E_T_ = ' ' ) TABIND "
cSQL += " GROUP BY U7_POSTO, C5_VEND2, B1_PROC, U7_CODVEN, C5_VEND1, C5_EMISSAO "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC9",.T.,.T.)  

TCSETFIELD("QRYSC9","C9_VALOR","N",17,2)

_nTel   := 0
_nPub   := 0
_nPar   := 0
_nRep   := 0
_nTot   := 0

While !QRYSC9->(Eof())                                         
	If _cEmpQry=="010"
		If ((Empty(QRYSC9->C5_VEND2) .OR. ;
			(!Empty(QRYSC9->C5_VEND2) .AND. !(QRYSC9->B1_PROC $ cFornVend))).AND. ;
			!Empty(QRYSC9->U7_CODVEN) .and. ;
			QRYSC9->C5_VEND1 <> '000204') .or. ;
			QRYSC9->C5_VEND1 $ '006684/000353/000352/000356/000357/000359'	
			
			DipSomFat("TEL",QRYSC9->C5_EMISSAO,QRYSC9->C9_VALOR,.T.)					
		Else
			If QRYSC9->U7_POSTO=="03"
				DipSomFat("PUB",QRYSC9->C5_EMISSAO,QRYSC9->C9_VALOR,.T.)
			Else
				DipSomFat("PAR",QRYSC9->C5_EMISSAO,QRYSC9->C9_VALOR,.T.)
			EndIf		
		EndIf
	Else 
		_nTot := QRYSC9->C9_VALOR
	EndIf
	QRYSC9->(dbSkip())	
EndDo
QRYSC9->(dbCloseArea())    
     
If _cEmpQry=="010"
	aAdd(aRet,_nPar)
	aAdd(aRet,_nPub)
	aAdd(aRet,_nRep)
	aAdd(aRet,_nTel)
	aAdd(aRet,_nTot)
Else 
	aAdd(aRet,_nTot)
EndIf	
Return(aRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfBusc_aMetaบAutor  ณJailton B Santos-JBSบ Data ณ 04/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca a meta de venda por departamento. Informa-se a o codi-บฑฑ
ฑฑบ          ณgo do vendedor.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEspecifico - Faturamento - Dipromed                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function DipCalMet(cVend,_cEmpQry)
Local cSQL 	  	:= ""
Local _nVlrMeta := 0
Local cMesAno 	:= SubStr(DtoS(Date()),5,2)+"/"+Left(DtoS(Date()),4)
DEFAULT cVend 	:= ""  
DEFAULT _cEmpQry:= "010"

cSQL := " SELECT 
cSQL += " 	ZF_VEND, ZF_META "
cSQL += " 	FROM "
cSQL += " 		SZF"+_cEmpQry+" WITH(NOLOCK) "
cSQL += " 		WHERE "
cSQL += " 			ZF_FILIAL 	IN(' ','01') AND "
cSQL += "			ZF_VEND 	= '"+cVend+"' AND "
cSQL += " 			ZF_MESANO 	= '"+cMesAno+"' AND "
cSQL += " 			D_E_L_E_T_ 	= ' ' "

//cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSZF",.T.,.T.)  

If !QRYSZF->(Eof())
	_nVlrMeta := QRYSZF->ZF_META
EndIf
QRYSZF->(dbCloseArea())

Return(_nVlrMeta)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPINDIC  บAutor  ณMicrosiga           บ Data ณ  07/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipSomFat(cEquipe,cEmissao,nValFat,lSoma)
DEFAULT cEquipe := ""
DEFAULT cEmissao:= ""
DEFAULT nValFat := 0                              
DEFAULT lSoma   := .F.                            

If cEquipe == "TEL"                 
	If lSoma
		_nTel += nValFat     
		If cEmissao == DtoS(Date())                                                 
			_nTelH += nValFat
	    ElseIf Day(Date())>1 .And. cEmissao == DtoS(DataValida(Date()-1,.F.))
	    	_nTelA += nValFat
	   	EndIf
	Else     
		_nTel -= nValFat     
		If cEmissao == DtoS(Date())                                                 
			_nTelH -= nValFat
	    ElseIf Day(Date())>1 .And. cEmissao == DtoS(DataValida(Date()-1,.F.))
	    	_nTelA -= nValFat
	   	EndIf	
	EndIf	
ElseIf cEquipe == "PUB"
	If lSoma
		If cEmissao == DtoS(Date())                                                 
			_nPubH += nValFat
			_nRepH += nValFat
	    ElseIf Day(Date())>1 .And. cEmissao == DtoS(DataValida(Date()-1,.F.))
	    	_nPubA += nValFat
	    	_nRepA += nValFat
		EndIf
		_nPub += nValFat
		_nRep += nValFat		
	Else
		If cEmissao == DtoS(Date())                                                 
			_nPubH -= nValFat
			_nRepH -= nValFat
	    ElseIf Day(Date())>1 .And. cEmissao == DtoS(DataValida(Date()-1,.F.))
	    	_nPubA -= nValFat
	    	_nRepA -= nValFat
		EndIf
		_nPub -= nValFat
		_nRep -= nValFat		
	EndIf
ElseIf cEquipe == "PAR
	If lSoma
		If cEmissao == DtoS(Date())                                                 
			_nParH += nValFat
			_nRepH += nValFat
	    ElseIf Day(Date())>1 .And. cEmissao == DtoS(DataValida(Date()-1,.F.))
	    	_nParA += nValFat
	    	_nRepA += nValFat
   		EndIf
		_nPar += nValFat
		_nRep += nValFat		
	Else
		If cEmissao == DtoS(Date())                                                 
			_nParH -= nValFat
			_nRepH -= nValFat
	    ElseIf Day(Date())>1 .And. cEmissao == DtoS(DataValida(Date()-1,.F.))
	    	_nParA -= nValFat
	    	_nRepA -= nValFat
    	EndIf
		_nPar -= nValFat
		_nRep -= nValFat		
	EndIf
EndIf  

If lSoma
	_nTot += nValFat
	
	If cEmissao == DtoS(Date())                                                 
		_nTotH +=	nValFat
	ElseIf Day(Date())>1 .And. cEmissao == DtoS(DataValida(Date()-1,.F.))
	   	_nTotA += nValFat
	EndIf
Else     
	_nTot -= nValFat
	
	If cEmissao == DtoS(Date())                                                 
		_nTotH -=	nValFat
	ElseIf Day(Date())>1 .And. cEmissao == DtoS(DataValida(Date()-1,.F.))
	   	_nTotA -= nValFat
	EndIf
EndIf	

Return 




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery04  บAutor  ณJailton B Santos-JBSบ Data ณ 03/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esta Query apura os falores faturado no pedido pela empresaบฑฑ
ฑฑบ          ณ informada como parametro, Retorna Query QRY1.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - Faturamento - DIPROMED.                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fQuery04(_cEmpQry)
Local cSQL    	 := ""
Local cAnoMes 	 := Left(Dtos(Date()),6)
Local aRet	  	 := {}  
DEFAULT _cEmpQry := ""

Private cFornVend  := AllTrim(GetNewPar("MV_FORNVEN",""))

cSQL := " SELECT TOP 10"
cSQL += " A1_NREDUZ, "
cSQL += " 		ROUND(SUM(CASE F4_DUPLIC WHEN 'S' THEN (D2_TOTAL+D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET ) ELSE (D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET ) END),2) AS F2_VALFAT "
cSQL += "   	FROM "
cSQL += "  			SF2"+_cEmpQry+" SF2 WITH(NOLOCK), SC5"+_cEmpQry+" SC5 WITH(NOLOCK), SU7010 SU7 WITH(NOLOCK), SD2"+_cEmpQry+" SD2 WITH(NOLOCK), SF4"+_cEmpQry+" SF4 WITH(NOLOCK), SA1"+_cEmpQry+" SA1 WITH(NOLOCK) "
cSQL += "  			WHERE "
cSQL += " 				F2_FILIAL IN('01','04') AND "
cSQL += " 				LEFT(F2_EMISSAO,6) = '"+cAnoMes+"' AND "
cSQL += " 				F2_TIPO IN ('N','C') AND "
cSQL += " 				F2_FILIAL  = D2_FILIAL AND "
cSQL += " 				F2_DOC     = D2_DOC AND "
cSQL += " 				F2_SERIE   = D2_SERIE AND " 
cSQL += " 				F2_CLIENTE = D2_CLIENTE AND "
cSQL += " 				F2_LOJA    = D2_LOJA AND "
cSQL += " 				F2_VEND1   <> '006874' AND "
cSQL += " 				D2_FILIAL  = F4_FILIAL AND "
cSQL += " 				D2_TES 	   = F4_CODIGO AND "
cSQL += " 				(F4_DUPLIC = 'S' or D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET  > 0 ) AND "
cSQL += " 				F4_FILIAL  = D2_FILIAL AND "
cSQL += " 				D2_FILIAL  = C5_FILIAL AND "
cSQL += " 				D2_PEDIDO  = C5_NUM AND "
cSQL += " 				D2_CLIENTE = C5_CLIENTE AND "
cSQL += " 				D2_LOJA    = C5_LOJACLI AND "
cSQL += " 				D2_CLIENTE = A1_COD AND "
cSQL += " 				D2_LOJA    = A1_LOJA AND "
cSQL += " 				U7_FILIAL  = ' ' AND "
cSQL += " 				C5_OPERADO = U7_COD AND "
cSQL += " 				SF2.D_E_L_E_T_ = ' ' AND "
cSQL += " 				SC5.D_E_L_E_T_ = ' ' AND "
cSQL += " 				SU7.D_E_L_E_T_ = ' ' AND "
cSQL += " 				SD2.D_E_L_E_T_ = ' ' AND "
cSQL += " 				SF4.D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY A1_NREDUZ "
cSQL += " ORDER BY ROUND(SUM(CASE F4_DUPLIC WHEN 'S' THEN (D2_TOTAL+D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET ) ELSE (D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET ) END),2) DESC"

//cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYGRA4",.T.,.T.)

TCSETFIELD("QRYGRA4","F2_VALFAT","N",17,2)

While !QRYGRA4->(Eof())                                                
	aAdd(aRet,{QRYGRA4->A1_NREDUZ, QRYGRA4->F2_VALFAT})

	QRYGRA4->(dbSkip())
EndDo
QRYGRA4->(dbCloseArea())  	

Return(aRet)
